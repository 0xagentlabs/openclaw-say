#!/usr/bin/env python3

import json
import os
import requests
import sys
import base64
import subprocess
import time

def get_today():
    from datetime import datetime
    return datetime.now().strftime('%Y-%m-%d')

def get_readme_content(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/readme"
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "OpenClaw-Say-Daily-Report"
    }
    
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"token {token}"
        
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            content = base64.b64decode(data['content']).decode('utf-8', errors='ignore')
            return content
        elif response.status_code == 404:
            print(f"⚠️ README not found for {owner}/{repo}")
            return None
        else:
            print(f"❌ Failed to get README for {owner}/{repo}: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error fetching README for {owner}/{repo}: {e}")
        return None

def analyze_with_gemini(readme_content, project_name):
    if not readme_content:
        return None
        
    # Truncate content to avoid token limits (e.g., first 15000 chars)
    truncated_content = readme_content[:15000]
    
    prompt = f"""
你是一个专业的技术分析师。请分析以下 GitHub 项目 ({project_name}) 的 README 内容，并生成一段详细的中文分析。
请直接返回一个合法的 JSON 对象，不要包含 Markdown 代码块标记（如 ```json），不要包含其他废话。

JSON 结构如下：
{{
  "introduction": "项目的详细介绍（200字以内）",
  "background": "应用背景和解决的问题",
  "implementation": "核心技术实现方式、架构或使用的模型/库",
  "extension": "如何扩展或自定义该项目",
  "highlights": "主要亮点和特色功能（列出3-5点）"
}}

README 内容：
{truncated_content}
"""

    try:
        # Call gemini CLI
        result = subprocess.run(
            ["gemini", prompt], 
            capture_output=True, 
            text=True,
            timeout=120  # 2 minutes timeout for LLM
        )
        
        if result.returncode != 0:
            print(f"❌ Gemini CLI error: {result.stderr}")
            return None
            
        output = result.stdout.strip()
        
        # Clean up Markdown code blocks if present
        if output.startswith("```json"):
            output = output[7:]
        if output.startswith("```"):
            output = output[3:]
        if output.endswith("```"):
            output = output[:-3]
            
        return json.loads(output.strip())
        
    except json.JSONDecodeError:
        print(f"❌ Failed to parse JSON from Gemini output for {project_name}")
        print(f"Output was: {output[:200]}...")
        return None
    except Exception as e:
        print(f"❌ Error calling Gemini for {project_name}: {e}")
        return None

def main():
    date_str = get_today()
    if len(sys.argv) > 1:
        date_str = sys.argv[1]
        
    file_path = f"../../data/github/{date_str}.json"
    abs_path = os.path.join(os.path.dirname(__file__), file_path)
    
    if not os.path.exists(abs_path):
        print(f"⚠️ Data file not found: {abs_path}")
        return

    print(f"📂 Reading data from {abs_path}")
    
    with open(abs_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    items = data.get('items', [])
    updated_count = 0
    
    for item in items:
        # Skip if already analyzed
        if 'analysis' in item and item['analysis']:
            continue
            
        full_name = item['title'] # "owner/repo"
        print(f"🔍 Analyzing {full_name}...")
        
        try:
            owner, repo = full_name.split('/')
            readme = get_readme_content(owner, repo)
            
            if readme:
                analysis = analyze_with_gemini(readme, full_name)
                if analysis:
                    item['analysis'] = analysis
                    updated_count += 1
                    print(f"✅ Analyzed {full_name}")
                else:
                    print(f"⚠️ Analysis failed for {full_name}")
            
            # Sleep briefly to avoid rate limits
            time.sleep(2)
            
        except Exception as e:
            print(f"❌ Error processing {full_name}: {e}")
            
    if updated_count > 0:
        with open(abs_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"💾 Updated {updated_count} projects in {abs_path}")
    else:
        print("🎉 No new projects to analyze.")

if __name__ == "__main__":
    main()
