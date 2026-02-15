#!/usr/bin/env node

/**
 * GitHub AI 项目采集脚本
 * 从 GitHub 搜索 API 获取热门 AI Agent 项目
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  searchQuery: 'ai agent created:>30days',
  sort: 'stars',
  order: 'desc',
  perPage: 50,
  maxResults: 20,
  filterDays: 3
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

    // 如果环境变量有 GitHub Token，使用它
    if (process.env.GITHUB_TOKEN) {
      options.headers['Authorization'] = `token ${process.env.GITHUB_TOKEN}`;
    }

    const req = https.get(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
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
 * 加载历史记录（用于过滤已展示项目）
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

/**
 * 保存历史记录
 */
function saveHistory(items) {
  const historyPath = path.join(__dirname, '../../data/github/history.json');
  const today = getToday();
  
  const history = loadHistory();
  const projectNames = items.map(item => item.full_name);
  
  // 添加今天的记录
  history.push({
    date: today,
    projects: projectNames
  });
  
  // 只保留最近 30 天的记录
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - 30);
  
  const filteredHistory = history.filter(h => {
    const hDate = new Date(h.date);
    return hDate >= cutoffDate;
  });
  
  // 确保目录存在
  const dir = path.dirname(historyPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  fs.writeFileSync(historyPath, JSON.stringify(filteredHistory, null, 2));
}

/**
 * 过滤最近展示过的项目
 */
function filterRecentProjects(items, days = 3) {
  const history = loadHistory();
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);
  
  // 获取最近 days 天内展示过的项目名称
  const recentProjects = new Set();
  history.forEach(h => {
    const hDate = new Date(h.date);
    if (hDate >= cutoffDate) {
      h.projects.forEach(p => recentProjects.add(p));
    }
  });
  
  console.log(`📊 历史记录中有 ${recentProjects.size} 个项目在最近 ${days} 天内展示过`);
  
  // 过滤掉已展示的项目
  const filtered = items.filter(item => !recentProjects.has(item.full_name));
  console.log(`📊 过滤后剩余 ${filtered.length} 个新项目`);
  
  return filtered;
}

/**
 * 转换 GitHub 项目为统一数据格式
 */
function convertToUnifiedFormat(repo) {
  return {
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
    publishedAt: new Date(repo.created_at).toISOString().split('T')[0],
    category: 'ai-agent'
  };
}

/**
 * 搜索 GitHub AI 项目
 */
async function searchGitHubProjects() {
  const searchDate = new Date();
  searchDate.setDate(searchDate.getDate() - 30);
  const dateStr = searchDate.toISOString().split('T')[0];
  
  const query = encodeURIComponent(`ai agent created:>${dateStr}`);
  const url = `https://api.github.com/search/repositories?q=${query}&sort=${CONFIG.sort}&order=${CONFIG.order}&per_page=${CONFIG.perPage}`;
  
  console.log('🔍 搜索 GitHub AI 项目...');
  console.log(`   URL: ${url}`);
  
  const data = await fetchJSON(url);
  
  if (!data.items || !Array.isArray(data.items)) {
    throw new Error('GitHub API 返回格式异常');
  }
  
  console.log(`✅ 找到 ${data.items.length} 个项目`);
  
  return data.items;
}

/**
 * 主函数
 */
async function main() {
  try {
    console.log('🚀 GitHub 采集器启动');
    console.log(`📅 日期: ${getToday()}`);
    
    // 搜索项目
    const allItems = await searchGitHubProjects();
    
    if (allItems.length === 0) {
      console.warn('⚠️ 未找到任何项目');
      process.exit(0);
    }
    
    // 过滤最近展示过的项目
    const filteredItems = filterRecentProjects(allItems, CONFIG.filterDays);
    
    // 取前 N 个
    const selectedItems = filteredItems.slice(0, CONFIG.maxResults);
    
    // 如果过滤后不够，从历史记录中补充
    if (selectedItems.length < CONFIG.maxResults && allItems.length >= CONFIG.maxResults) {
      console.log('⚠️ 新项目不足，从历史记录中补充...');
      const needed = CONFIG.maxResults - selectedItems.length;
      const existingNames = new Set(selectedItems.map(i => i.full_name));
      const additional = allItems
        .filter(item => !existingNames.has(item.full_name))
        .slice(0, needed);
      selectedItems.push(...additional);
    }
    
    console.log(`✅ 最终选择 ${selectedItems.length} 个项目`);
    
    // 转换为统一格式
    const unifiedData = selectedItems.map(convertToUnifiedFormat);
    
    // 保存数据
    const outputPath = path.join(__dirname, `../../data/github/${getToday()}.json`);
    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    fs.writeFileSync(outputPath, JSON.stringify({
      date: getToday(),
      count: unifiedData.length,
      items: unifiedData
    }, null, 2));
    
    console.log(`💾 数据已保存: ${outputPath}`);
    
    // 更新历史记录
    saveHistory(selectedItems);
    console.log('📝 历史记录已更新');
    
    console.log('\n📋 采集的项目列表:');
    unifiedData.forEach((item, i) => {
      console.log(`  ${i + 1}. ${item.title} ⭐ ${item.metadata.stars}`);
    });
    
    console.log('\n✅ GitHub 采集完成!');
    
  } catch (error) {
    console.error('❌ 采集失败:', error.message);
    process.exit(1);
  }
}

// 运行主函数
main();
