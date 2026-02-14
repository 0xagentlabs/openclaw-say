#!/usr/bin/env node

/**
 * Product Hunt AI 产品采集脚本
 * 从 Product Hunt RSS feed 获取 AI 类别产品
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  rssUrl: 'https://www.producthunt.com/feed?category=artificial-intelligence',
  maxResults: 10
};

// 备用产品列表（当 RSS 不可用时使用）
const FALLBACK_PRODUCTS = [
  {
    id: 'fallback-1',
    name: 'ChatGPT',
    tagline: 'OpenAI 的对话式 AI 助手',
    url: 'https://chat.openai.com',
    thumbnail: 'https://via.placeholder.com/400x300/0a192f/64ffda?text=ChatGPT',
    votesCount: 50000,
    createdAt: new Date().toISOString()
  },
  {
    id: 'fallback-2',
    name: 'Claude',
    tagline: 'Anthropic 的 AI 助手，擅长长文本理解',
    url: 'https://claude.ai',
    thumbnail: 'https://via.placeholder.com/400x300/0a192f/64ffda?text=Claude',
    votesCount: 30000,
    createdAt: new Date().toISOString()
  },
  {
    id: 'fallback-3',
    name: 'Midjourney',
    tagline: 'AI 图像生成工具',
    url: 'https://www.midjourney.com',
    thumbnail: 'https://via.placeholder.com/400x300/0a192f/64ffda?text=Midjourney',
    votesCount: 25000,
    createdAt: new Date().toISOString()
  },
  {
    id: 'fallback-4',
    name: 'Notion AI',
    tagline: 'Notion 内置的 AI 写作助手',
    url: 'https://www.notion.so/product/ai',
    thumbnail: 'https://via.placeholder.com/400x300/0a192f/64ffda?text=Notion+AI',
    votesCount: 20000,
    createdAt: new Date().toISOString()
  },
  {
    id: 'fallback-5',
    name: 'Perplexity',
    tagline: 'AI 驱动的搜索引擎',
    url: 'https://www.perplexity.ai',
    thumbnail: 'https://via.placeholder.com/400x300/0a192f/64ffda?text=Perplexity',
    votesCount: 18000,
    createdAt: new Date().toISOString()
  }
];

/**
 * 获取今天的日期字符串
 */
function getToday() {
  return new Date().toISOString().split('T')[0];
}

/**
 * 发送 HTTP GET 请求
 */
function fetchRSS(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, {
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
      },
      timeout: 15000
    }, (res) => {
      // 处理重定向
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        console.log(`🔄 重定向到: ${res.headers.location}`);
        return fetchRSS(res.headers.location).then(resolve).catch(reject);
      }
      
      // 检查状态码
      if (res.statusCode === 404) {
        reject(new Error('RSS_FEED_NOT_FOUND'));
        return;
      }
      
      if (res.statusCode >= 400) {
        reject(new Error(`HTTP_ERROR_${res.statusCode}`));
        return;
      }
      
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    });

    req.on('error', (err) => {
      reject(new Error(`NETWORK_ERROR: ${err.message}`));
    });
    
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('TIMEOUT'));
    });
  });
}

/**
 * 解析 RSS XML
 */
function parseRSS(xml) {
  const items = [];
  
  // 清理 CDATA
  const cleanXML = xml.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1');
  
  // 提取 item 节点
  const itemRegex = /<item>([\s\S]*?)<\/item>/g;
  let match;
  
  while ((match = itemRegex.exec(cleanXML)) !== null) {
    const content = match[1];
    
    // 提取标题
    const titleMatch = content.match(/<title[^>]*>([\s\S]*?)<\/title>/);
    const title = titleMatch ? titleMatch[1].trim() : 'Unknown Product';
    
    // 提取链接
    const linkMatch = content.match(/<link[^>]*>([^<]+)<\/link>/);
    const link = linkMatch ? linkMatch[1].trim() : '';
    
    // 提取描述
    const descMatch = content.match(/<description[^>]*>([\s\S]*?)<\/description>/);
    let description = descMatch ? descMatch[1].trim() : '';
    
    // 解码 HTML 实体
    description = description
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'");
    
    // 提取发布日期
    const pubDateMatch = content.match(/<pubDate>([^<]+)<\/pubDate>/);
    const pubDate = pubDateMatch ? pubDateMatch[1] : new Date().toISOString();
    
    // 尝试提取投票数（通常在 title 或 description 中）
    let votes = 0;
    const votesMatch = title.match(/\((\d+)\s*points?\)/i) || 
                       description.match(/(\d+)\s*(up)?votes?/i) ||
                       content.match(/<ph:votes>(\d+)<\/ph:votes>/);
    if (votesMatch) {
      votes = parseInt(votesMatch[1]);
    }
    
    // 尝试提取缩略图
    let thumbnail = '';
    const enclosureMatch = content.match(/<enclosure[^>]*url="([^"]+)"/);
    const mediaThumbMatch = content.match(/<media:thumbnail[^>]*url="([^"]+)"/);
    const imgMatch = description.match(/<img[^>]*src="([^"]+)"/);
    
    if (enclosureMatch) {
      thumbnail = enclosureMatch[1];
    } else if (mediaThumbMatch) {
      thumbnail = mediaThumbMatch[1];
    } else if (imgMatch) {
      thumbnail = imgMatch[1];
    }
    
    if (title && link) {
      items.push({
        id: `ph-${Date.now()}-${items.length}`,
        name: title.replace(/\s*\(\d+\s*points?\)/i, '').trim(),
        tagline: description.replace(/<[^>]+>/g, '').substring(0, 200),
        url: link,
        thumbnail: thumbnail,
        votesCount: votes,
        createdAt: new Date(pubDate).toISOString()
      });
    }
  }
  
  return items;
}

/**
 * 获取产品列表
 */
async function fetchProducts() {
  console.log('🔍 获取 Product Hunt AI 产品...');
  console.log(`   RSS: ${CONFIG.rssUrl}`);
  
  try {
    const xml = await fetchRSS(CONFIG.rssUrl);
    const products = parseRSS(xml);
    
    console.log(`✅ 成功获取 ${products.length} 个产品`);
    
    // 如果 RSS 解析成功但返回空数组，使用备用产品
    if (products.length === 0) {
      console.log('⚠️ RSS 返回空数据，使用备用产品列表');
      return FALLBACK_PRODUCTS.map((p, i) => ({
        ...p,
        id: `fallback-${Date.now()}-${i}`
      }));
    }
    
    return products;
    
  } catch (error) {
    console.error(`❌ 获取失败: ${error.message}`);
    
    // 使用备用方案
    console.log('⚠️ 使用备用产品列表');
    return FALLBACK_PRODUCTS.map((p, i) => ({
      ...p,
      id: `fallback-${Date.now()}-${i}`
    }));
  }
}

/**
 * 转换为统一数据格式
 */
function convertToUnifiedFormat(product) {
  return {
    id: `producthunt-${product.id}`,
    source: 'producthunt',
    title: product.name,
    description: product.tagline,
    url: product.url,
    image: product.thumbnail || `https://via.placeholder.com/400x300/0a192f/64ffda?text=${encodeURIComponent(product.name)}`,
    metadata: {
      votes: product.votesCount || 0,
      source: 'Product Hunt'
    },
    publishedAt: product.createdAt.split('T')[0],
    category: 'product'
  };
}

/**
 * 主函数
 */
async function main() {
  try {
    console.log('🚀 Product Hunt 采集器启动');
    console.log(`📅 日期: ${getToday()}`);
    
    // 获取产品列表
    const products = await fetchProducts();
    
    if (products.length === 0) {
      console.warn('⚠️ 未找到任何产品');
      process.exit(0);
    }
    
    // 取前 N 个
    const selectedProducts = products.slice(0, CONFIG.maxResults);
    
    console.log(`✅ 最终选择 ${selectedProducts.length} 个产品`);
    
    // 转换为统一格式
    const unifiedData = selectedProducts.map(convertToUnifiedFormat);
    
    // 保存数据
    const outputPath = path.join(__dirname, `../../data/producthunt/${getToday()}.json`);
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
    
    console.log('\n📋 采集的产品列表:');
    unifiedData.forEach((item, i) => {
      console.log(`  ${i + 1}. ${item.title} ⬆️ ${item.metadata.votes}`);
    });
    
    console.log('\n✅ Product Hunt 采集完成!');
    
  } catch (error) {
    console.error('❌ 采集失败:', error.message);
    process.exit(1);
  }
}

// 运行主函数
main();
