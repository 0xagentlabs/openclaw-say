#!/usr/bin/env node

/**
 * GitHub AI 项目采集脚本
 * 1. 搜索热门 AI Agent 项目
 * 2. 拉取 README 内容
 * 3. 调用 Gemini 进行深度分析（介绍、背景、实现、扩展、亮点）
 */

const https = require('https');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 配置
const CONFIG = {
  searchQuery: 'ai agent created:>30days',
  sort: 'stars',
  order: 'desc',
  perPage: 50,
  maxResults: 20,
  filterDays: 3,
  geminiModel: 'gemini-1.5-flash' // 使用 Flash 模型以获得更快的速度和更低的成本
};

/**
 * 获取今天的日期字符串
 */
function getToday() {
  return new Date().toISOString().split('T')[0];
}

/**
 * 发送 HTTP GET 请求
 */
function fetchJSON(url, headers = {}) {
  return new Promise((resolve, reject) => {
    const options = {
      method: 'GET',
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'OpenClaw-Say-Daily-Report',
        ...headers
      }
    };

    if (process.env.GITHUB_TOKEN) {
      options.headers['Authorization'] = `token ${process.env.GITHUB_TOKEN}`;
    }

    const req = https.get(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          if (res.statusCode >= 400) {
            reject(new Error(`HTTP Error: ${res.statusCode} ${res.statusMessage}`));
            return;
          }
          const json = JSON.parse(data);
          resolve(json);
        } catch (e) {
          reject(new Error(`解析 JSON 失败: ${e.message}`));
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(30000, () => {
      req.destroy();
      reject(new Error('请求超时'));
    });
  });
}

/**
 * 获取 GitHub 仓库的 README 内容
 */
async function fetchReadme(owner, repo) {
  try {
    const url = `https://api.github.com/repos/${owner}/${repo}/readme`;
    const data = await fetchJSON(url);
    if (data && data.content) {
      return Buffer.from(data.content, 'base64').toString('utf-8');
    }
    return '';
  } catch (error) {
    console.warn(`⚠️ 无法获取 README (${owner}/${repo}): ${error.message}`);
    return '';
  }
}

/**
 * 使用 Gemini 分析 README 内容
 */
function analyzeWithGemini(readmeContent, repoName) {
  if (!readmeContent || readmeContent.length < 100) {
    return null;
  }

  // 截断过长的 README 以节省 Token
  const truncatedReadme = readmeContent.slice(0, 15000);

  const prompt = `
你是一个专业的 AI 技术分析师。请根据以下 GitHub 项目 (${repoName}) 的 README 内容，生成一份深度分析报告。

README 内容摘要:
${truncatedReadme}

请输出严格的 JSON 格式，包含以下 5 个字段（不要使用 Markdown 代码块，直接输出 JSON）：
1. "summary": 项目简介（一句话概括核心功能）
2. "background": 应用背景（解决什么问题，适用场景）
3. "implementation": 实现方式（技术栈、核心架构、模型使用）
4. "extension": 扩展方式（如何二次开发、插件机制）
5. "highlights": 亮点（创新点、性能优势、与其他项目的区别）

JSON 结构示例:
{
  "summary": "...",
  "background": "...",
  "implementation": "...",
  "extension": "...",
  "highlights": "..."
}
`;

  try {
    // 使用 gemini CLI 调用模型
    // 注意：这里需要处理转义字符，避免 shell 命令错误
    // 简单起见，我们将 prompt 写入临时文件
    const tmpFile = `/tmp/gemini_prompt_${Date.now()}.txt`;
    fs.writeFileSync(tmpFile, prompt);

    const cmd = `gemini "$(cat ${tmpFile})"`;
    const result = execSync(cmd, { encoding: 'utf-8', timeout: 60000 });
    
    fs.unlinkSync(tmpFile); // 清理临时文件

    // 尝试解析 JSON
    // 有时模型会输出 ```json ... ```，需要清理
    let jsonStr = result.trim();
    if (jsonStr.startsWith('```json')) {
      jsonStr = jsonStr.replace(/^```json/, '').replace(/```$/, '');
    } else if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.replace(/^```/, '').replace(/```$/, '');
    }

    return JSON.parse(jsonStr);
  } catch (error) {
    console.warn(`⚠️ Gemini 分析失败 (${repoName}): ${error.message}`);
    return null;
  }
}

/**
 * 加载/保存历史记录 (复用原逻辑)
 */
function loadHistory() {
  const historyPath = path.join(__dirname, '../../data/github/history.json');
  try {
    if (fs.existsSync(historyPath)) {
      return JSON.parse(fs.readFileSync(historyPath, 'utf8'));
    }
  } catch (e) {
    console.warn('⚠️ 读取历史记录失败:', e.message);
  }
  return [];
}

function saveHistory(items) {
  const historyPath = path.join(__dirname, '../../data/github/history.json');
  const today = getToday();
  const history = loadHistory();
  const projectNames = items.map(item => item.full_name);
  history.push({ date: today, projects: projectNames });
  
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - 30);
  const filteredHistory = history.filter(h => new Date(h.date) >= cutoffDate);
  
  const dir = path.dirname(historyPath);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(historyPath, JSON.stringify(filteredHistory, null, 2));
}

function filterRecentProjects(items, days = 3) {
  const history = loadHistory();
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);
  const recentProjects = new Set();
  history.forEach(h => {
    if (new Date(h.date) >= cutoffDate) h.projects.forEach(p => recentProjects.add(p));
  });
  return items.filter(item => !recentProjects.has(item.full_name));
}

/**
 * 转换并增强 GitHub 项目数据
 */
async function processProjects(repos) {
  const unifiedData = [];

  for (const repo of repos) {
    console.log(`🤖 正在深度分析: ${repo.full_name}...`);
    
    // 1. 获取 README
    const readme = await fetchReadme(repo.owner.login, repo.name);
    
    // 2. Gemini 分析
    let analysis = null;
    if (readme) {
      analysis = analyzeWithGemini(readme, repo.full_name);
    }

    // 3. 构建数据
    const item = {
      id: `github-${repo.id}`,
      source: 'github',
      title: repo.full_name,
      description: repo.description || '暂无描述',
      url: repo.html_url,
      image: `https://opengraph.githubassets.com/1/${repo.full_name}`,
      metadata: {
        stars: repo.stargazers_count || 0,
        language: repo.language || 'Unknown',
        topics: repo.topics || [],
        updatedAt: repo.updated_at,
        createdAt: repo.created_at
      },
      analysis: analysis || {
        summary: repo.description || "暂无详细分析",
        background: "未能获取",
        implementation: "未能获取",
        extension: "未能获取",
        highlights: "未能获取"
      },
      publishedAt: new Date(repo.created_at).toISOString().split('T')[0],
      category: 'ai-agent'
    };
    
    unifiedData.push(item);
  }
  
  return unifiedData;
}

/**
 * 搜索 GitHub AI 项目
 */
async function searchGitHubProjects() {
  const searchDate = new Date();
  searchDate.setDate(searchDate.getDate() - 30);
  const dateStr = searchDate.toISOString().split('T')[0];
  
  // 动态构建查询：关键词 + 创建时间过滤
  const q = `ai agent created:>${dateStr}`;
  const query = encodeURIComponent(q);
  
  const url = `https://api.github.com/search/repositories?q=${query}&sort=${CONFIG.sort}&order=${CONFIG.order}&per_page=${CONFIG.perPage}`;
  
  console.log('🔍 搜索 GitHub AI 项目...');
  const data = await fetchJSON(url);
  if (!data.items || !Array.isArray(data.items)) throw new Error('GitHub API 返回格式异常');
  return data.items;
}

/**
 * 主函数
 */
async function main() {
  try {
    console.log('🚀 GitHub 深度采集器启动 (with Gemini)');
    console.log(`📅 日期: ${getToday()}`);
    
    // 搜索
    const allItems = await searchGitHubProjects();
    if (allItems.length === 0) {
      console.warn('⚠️ 未找到项目');
      process.exit(0);
    }
    
    // 过滤
    let selectedItems = filterRecentProjects(allItems, CONFIG.filterDays);
    selectedItems = selectedItems.slice(0, CONFIG.maxResults);
    
    // 补充
    if (selectedItems.length < CONFIG.maxResults && allItems.length >= CONFIG.maxResults) {
      const needed = CONFIG.maxResults - selectedItems.length;
      const existingNames = new Set(selectedItems.map(i => i.full_name));
      const additional = allItems.filter(item => !existingNames.has(item.full_name)).slice(0, needed);
      selectedItems.push(...additional);
    }
    
    console.log(`✅ 选中 ${selectedItems.length} 个项目，开始深度分析...`);
    
    // 处理（拉取 README + Gemini 分析）
    const unifiedData = await processProjects(selectedItems);
    
    // 保存
    const outputPath = path.join(__dirname, `../../data/github/${getToday()}.json`);
    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    
    fs.writeFileSync(outputPath, JSON.stringify({
      date: getToday(),
      count: unifiedData.length,
      items: unifiedData
    }, null, 2));
    
    // 更新历史
    saveHistory(selectedItems);
    
    console.log(`💾 数据已保存: ${outputPath}`);
    console.log('\n✅ GitHub 深度采集完成!');
    
  } catch (error) {
    console.error('❌ 采集失败:', error.message);
    process.exit(1);
  }
}

main();
