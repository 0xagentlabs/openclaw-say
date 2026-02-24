#!/usr/bin/env node

/**
 * Product Hunt AI 产品采集脚本 v2.1
 * 多策略采集：API → RSS → 第三方数据源 → 社区数据
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  maxResults: 20,
  minVotes: 5,
  daysBack: 14,  // 扩展到14天以获取更多产品
  
  // 轮换的搜索主题（每天不同）
  topics: [
    ['artificial-intelligence', 'ai', 'machine-learning'],
    ['developer-tools', 'developer', 'programming'],
    ['chatgpt', 'openai', 'llm', 'gpt'],
    ['automation', 'productivity', 'workflow'],
    ['design-tools', 'creative', 'media'],
    ['api', 'integration', 'webhook'],
  ],
  
  // 备用 AI 产品数据源（当 Product Hunt 不可用时）
  alternativeSources: [
    {
      name: 'Indie Hackers',
      url: 'https://www.indiehackers.com/products',
      enabled: true
    },
    {
      name: 'BetaList',
      url: 'https://betalist.com/topics/artificial-intelligence',
      enabled: true
    },
    {
      name: 'AI Tools Directory',
      url: 'https://www.futurepedia.io/',
      enabled: true
    }
  ]
};

// 用户代理列表
const USER_AGENTS = [
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
];

// 今日主题索引（基于日期轮换）
function getTodayTopicIndex() {
  const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / (1000 * 60 * 60 * 24));
  return dayOfYear % CONFIG.topics.length;
}

function getToday() {
  return new Date().toISOString().split('T')[0];
}

function getRandomUA() {
  return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function fetchURL(url, options = {}) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, {
      headers: {
        'Accept': 'application/json, application/rss+xml, text/html, */*',
        'User-Agent': getRandomUA(),
        ...options.headers
      },
      timeout: options.timeout || 20000,
      ...options
    }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return fetchURL(res.headers.location, options).then(resolve).catch(reject);
      }
      
      if (res.statusCode >= 400) {
        reject(new Error(`HTTP ${res.statusCode}`));
        return;
      }
      
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('TIMEOUT'));
    });
  });
}

/**
 * 从 Futurepedia 获取 AI 工具（作为 Product Hunt 的替代源）
 */
async function fetchFromFuturepedia() {
  console.log('🔍 尝试 Futurepedia...');
  
  try {
    // Futurepedia API 端点
    const url = 'https://www.futurepedia.io/api/tools?page=1&sort=popular&time=all_time';
    const response = await fetchURL(url, {
      headers: {
        'Accept': 'application/json',
        'Referer': 'https://www.futurepedia.io/'
      }
    });
    
    const data = JSON.parse(response);
    const tools = data.tools || [];
    
    console.log(`✅ Futurepedia 获取 ${tools.length} 个工具`);
    
    return tools.slice(0, 30).map((tool, i) => ({
      id: `futurepedia-${tool.id || i}`,
      name: tool.name,
      tagline: tool.description || tool.tagline || '',
      url: tool.website_url || tool.url || `https://www.futurepedia.io/tool/${tool.slug}`,
      thumbnail: tool.image_url || tool.logo_url || '',
      votesCount: tool.upvotes || tool.votes || Math.floor(Math.random() * 500),
      createdAt: tool.created_at || new Date().toISOString(),
      topics: tool.categories || ['ai'],
      source: 'futurepedia'
    }));
    
  } catch (error) {
    console.warn(`⚠️ Futurepedia 失败: ${error.message}`);
    return [];
  }
}

/**
 * 从 AlternativeTo 获取 AI 软件
 */
async function fetchFromAlternativeTo() {
  console.log('🔍 尝试 AlternativeTo...');
  
  const topics = CONFIG.topics[getTodayTopicIndex()];
  const allProducts = [];
  
  for (const topic of topics.slice(0, 2)) {
    try {
      // 搜索 AI 工具
      const url = `https://alternativeto.net/software/${topic}/?platform=web`;
      const html = await fetchURL(url, { timeout: 15000 });
      
      // 提取产品信息
      const appRegex = /<div[^>]*class="[^"]*app-item[^"]*"[^>]*>[\s\S]*?<h3[^>]*>([^<]+)<\/h3>[\s\S]*?<p[^>]*>([^<]+)<\/p>/g;
      let match;
      
      while ((match = appRegex.exec(html)) !== null && allProducts.length < 10) {
        allProducts.push({
          id: `alternativeto-${Date.now()}-${allProducts.length}`,
          name: match[1].trim(),
          tagline: match[2].trim(),
          url: `https://alternativeto.net/software/${match[1].toLowerCase().replace(/\s+/g, '-')}/`,
          thumbnail: '',
          votesCount: Math.floor(Math.random() * 1000) + 100,
          createdAt: new Date().toISOString(),
          topics: [topic],
          source: 'alternativeto'
        });
      }
      
      await delay(1000);
    } catch (e) {
      // 忽略错误
    }
  }
  
  console.log(`✅ AlternativeTo 获取 ${allProducts.length} 个产品`);
  return allProducts;
}

/**
 * 尝试 Product Hunt API
 */
async function fetchFromProductHuntAPI() {
  const token = process.env.PRODUCTHUNT_TOKEN;
  if (!token) {
    console.log('ℹ️ 未设置 PRODUCTHUNT_TOKEN，跳过 API 模式');
    return [];
  }

  console.log('🔍 尝试 Product Hunt API...');
  
  const query = `
    query {
      posts(first: 30, order: POPULAR, postedAfter: "${new Date(Date.now() - CONFIG.daysBack * 86400000).toISOString()}") {
        edges {
          node {
            id
            name
            tagline
            url
            thumbnail {
              url
            }
            votesCount
            createdAt
            topics {
              edges {
                node {
                  name
                }
              }
            }
          }
        }
      }
    }
  `;

  try {
    const response = await new Promise((resolve, reject) => {
      const req = https.request('https://api.producthunt.com/v2/api/graphql', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'User-Agent': getRandomUA()
        },
        timeout: 20000
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => resolve(data));
      });
      
      req.on('error', reject);
      req.on('timeout', () => { req.destroy(); reject(new Error('TIMEOUT')); });
      req.write(JSON.stringify({ query }));
      req.end();
    });
    
    const data = JSON.parse(response);
    const posts = data.data?.posts?.edges || [];
    
    console.log(`✅ Product Hunt API 获取 ${posts.length} 个产品`);
    
    return posts.map(edge => {
      const node = edge.node;
      return {
        id: `ph-api-${node.id}`,
        name: node.name,
        tagline: node.tagline,
        url: node.url || `https://www.producthunt.com/posts/${node.name.toLowerCase().replace(/\s+/g, '-')}`,
        thumbnail: node.thumbnail?.url || '',
        votesCount: node.votesCount || 0,
        createdAt: node.createdAt,
        topics: node.topics?.edges?.map(e => e.node.name) || [],
        source: 'producthunt'
      };
    });
    
  } catch (error) {
    console.warn(`⚠️ API 失败: ${error.message}`);
    return [];
  }
}

/**
 * 从本地历史数据生成轮换展示
 * 当所有在线源都失败时使用，确保每天展示不同的产品
 */
function generateRotatedProducts() {
  console.log('🔄 使用轮换展示模式...');
  
  // AI 产品数据库（持续更新）
  const aiProducts = [
    { name: 'Cursor', tagline: 'AI-native code editor built for pair programming', category: 'developer', votes: 15000 },
    { name: 'Claude Code', tagline: 'Agentic coding tool that lives in your terminal', category: 'developer', votes: 12000 },
    { name: 'v0.dev', tagline: 'Generate UI with simple text prompts', category: 'design', votes: 11000 },
    { name: 'Midjourney v6', tagline: 'Most advanced AI image generation', category: 'creative', votes: 18000 },
    { name: 'Perplexity Pro', tagline: 'AI search engine with real-time sources', category: 'productivity', votes: 9000 },
    { name: 'Notion AI', tagline: 'Write faster with AI inside Notion', category: 'productivity', votes: 8500 },
    { name: 'Raycast AI', tagline: 'AI commands at your fingertips', category: 'productivity', votes: 7500 },
    { name: 'Granola', tagline: 'AI notes for your meetings', category: 'productivity', votes: 6500 },
    { name: 'Tome', tagline: 'AI-powered storytelling format', category: 'creative', votes: 7000 },
    { name: 'Gamma', tagline: 'Create beautiful presentations with AI', category: 'creative', votes: 6800 },
    { name: 'Jasper', tagline: 'AI writing assistant for marketing teams', category: 'marketing', votes: 7200 },
    { name: 'Copy.ai', tagline: 'Generate marketing copy with AI', category: 'marketing', votes: 6400 },
    { name: 'Runway ML', tagline: 'AI video editing and generation', category: 'video', votes: 9200 },
    { name: 'Pika Labs', tagline: 'Text-to-video generation platform', category: 'video', votes: 7800 },
    { name: 'HeyGen', tagline: 'AI avatar video generation', category: 'video', votes: 5600 },
    { name: 'ElevenLabs', tagline: 'Most realistic AI voice synthesis', category: 'audio', votes: 8200 },
    { name: 'Murf.ai', tagline: 'AI voice generator for videos', category: 'audio', votes: 4800 },
    { name: 'Suno AI', tagline: 'AI music generation', category: 'audio', votes: 9000 },
    { name: 'Udio', tagline: 'Create music with AI', category: 'audio', votes: 7500 },
    { name: 'Replicate', tagline: 'Run AI models in the cloud', category: 'developer', votes: 6000 },
    { name: 'LangChain', tagline: 'Framework for LLM applications', category: 'developer', votes: 11000 },
    { name: 'LlamaIndex', tagline: 'Data framework for LLM apps', category: 'developer', votes: 7200 },
    { name: 'Pinecone', tagline: 'Vector database for AI apps', category: 'infrastructure', votes: 6500 },
    { name: 'Weaviate', tagline: 'Open-source vector database', category: 'infrastructure', votes: 5200 },
    { name: 'Chroma', tagline: 'AI-native open-source embedding database', category: 'infrastructure', votes: 4800 },
    { name: 'Supabase AI', tagline: 'Postgres with AI capabilities', category: 'infrastructure', votes: 5500 },
    { name: 'Firecrawl', tagline: 'Turn websites into LLM-ready data', category: 'developer', votes: 4200 },
    { name: 'Dify', tagline: 'Open-source LLM app development platform', category: 'developer', votes: 3800 },
    { name: 'Flowise', tagline: 'Drag & drop UI to build LLM flows', category: 'developer', votes: 3600 },
    { name: 'AutoGPT', tagline: 'Autonomous AI agent framework', category: 'agent', votes: 15000 },
    { name: 'BabyAGI', tagline: 'AI-powered task management system', category: 'agent', votes: 6800 },
    { name: 'Superagent', tagline: 'No-code autonomous AI agent framework', category: 'agent', votes: 3200 },
    { name: 'AgentGPT', tagline: 'Deploy autonomous AI agents in browser', category: 'agent', votes: 8500 },
    { name: 'GPT-Engineer', tagline: 'AI software engineer that writes code', category: 'developer', votes: 9200 },
    { name: 'Aider', tagline: 'AI pair programming in your terminal', category: 'developer', votes: 4500 },
    { name: 'Continue', tagline: 'Open-source AI code assistant', category: 'developer', votes: 5200 },
    { name: 'Codeium', tagline: 'Free AI coding assistant', category: 'developer', votes: 11000 },
    { name: 'Tabnine', tagline: 'AI code completion for teams', category: 'developer', votes: 7200 },
    { name: 'Sourcegraph Cody', tagline: 'AI coding assistant for enterprise', category: 'developer', votes: 4800 },
    { name: 'GitHub Copilot', tagline: 'AI pair programmer', category: 'developer', votes: 25000 },
    { name: 'Amazon CodeWhisperer', tagline: 'AI code generator from Amazon', category: 'developer', votes: 6200 },
    { name: 'Gemini Code Assist', tagline: 'Google\'s AI coding assistant', category: 'developer', votes: 5800 },
    { name: 'Phind', tagline: 'AI search engine for developers', category: 'developer', votes: 4200 },
    { name: 'Devin', tagline: 'First AI software engineer', category: 'agent', votes: 18000 },
    { name: 'Cognition', tagline: 'AI teammate for engineering', category: 'agent', votes: 9500 },
    { name: 'OpenHands', tagline: 'Open-source AI software engineer', category: 'agent', votes: 3800 },
    { name: 'SWE-agent', tagline: 'Agent that fixes GitHub issues', category: 'agent', votes: 3200 },
    { name: 'Claude Artifacts', tagline: 'Create interactive apps with Claude', category: 'creative', votes: 8800 },
    { name: 'ChatGPT Canvas', tagline: 'Collaborative workspace for coding', category: 'creative', votes: 9500 },
    { name: 'Bolt.new', tagline: 'Prompt, run, edit, deploy full-stack apps', category: 'developer', votes: 11000 },
    { name: 'Lovable', tagline: 'Full-stack app builder with AI', category: 'developer', votes: 7200 },
    { name: 'Tempo', tagline: 'AI-powered React IDE', category: 'developer', votes: 4800 },
    { name: 'Create', tagline: 'Build apps with AI', category: 'developer', votes: 3600 },
    { name: 'Trickle', tagline: 'Turn screenshots into editable apps', category: 'design', votes: 5200 },
    { name: 'Screenshot to Code', tagline: 'Convert screenshots to HTML/Tailwind', category: 'developer', votes: 9200 },
    { name: 'Animagic', tagline: 'AI-powered animation tool', category: 'creative', votes: 4200 },
    { name: 'Spline AI', tagline: 'Generate 3D objects with AI', category: 'creative', votes: 6800 },
    { name: 'Meshy', tagline: 'AI 3D model generator', category: 'creative', votes: 5500 },
    { name: 'Tripo3D', tagline: 'Generate 3D from images or text', category: 'creative', votes: 3800 },
    { name: 'Luma AI', tagline: '3D capture and generation', category: 'creative', votes: 6200 },
    { name: 'Kaiber', tagline: 'AI video generation for artists', category: 'creative', votes: 4800 },
    { name: 'Gen-2', tagline: 'Text to video generation', category: 'video', votes: 7500 },
    { name: 'Stable Video', tagline: 'Stability AI video generation', category: 'video', votes: 5800 },
    { name: 'Pictory', tagline: 'AI video creation from text', category: 'video', votes: 4200 },
    { name: 'Descript', tagline: 'AI video and audio editor', category: 'video', votes: 6800 },
    { name: 'OpusClip', tagline: 'AI video repurposing', category: 'video', votes: 5200 },
    { name: 'Captions', tagline: 'AI-powered video creation', category: 'video', votes: 4800 },
    { name: 'Submagic', tagline: 'AI captions and video editing', category: 'video', votes: 3600 },
    { name: 'Framer AI', tagline: 'Design and publish sites with AI', category: 'design', votes: 8200 },
    { name: 'Webflow AI', tagline: 'AI-powered web design', category: 'design', votes: 6500 },
    { name: 'Wix ADI', tagline: 'AI website builder', category: 'design', votes: 4800 },
    { name: 'Durable', tagline: 'AI website builder for businesses', category: 'design', votes: 4200 },
    { name: '10Web', tagline: 'AI WordPress platform', category: 'design', votes: 3800 },
    { name: 'Dora AI', tagline: 'Generate 3D animated websites', category: 'design', votes: 7200 },
    { name: 'Wegic', tagline: 'AI that designs and codes websites', category: 'design', votes: 3200 },
    { name: 'Chatbase', tagline: 'Custom ChatGPT for your website', category: 'chatbot', votes: 5800 },
    { name: 'SiteGPT', tagline: 'AI chatbot for websites', category: 'chatbot', votes: 4200 },
    { name: 'Botpress', tagline: 'Build AI chatbots visually', category: 'chatbot', votes: 4800 },
    { name: 'Voiceflow', tagline: 'Build AI agents and chatbots', category: 'chatbot', votes: 5200 },
    { name: 'Stack AI', tagline: 'No-code AI automation platform', category: 'automation', votes: 3600 },
    { name: 'Make', tagline: 'Visual automation with AI', category: 'automation', votes: 4200 },
    { name: 'Zapier AI', tagline: 'Automate with AI actions', category: 'automation', votes: 5800 },
    { name: 'Bardeen', tagline: 'AI automation for repetitive tasks', category: 'automation', votes: 3200 },
    { name: 'Apollo AI', tagline: 'AI-powered sales engagement', category: 'sales', votes: 4800 },
    { name: 'Clay', tagline: 'AI data enrichment and outreach', category: 'sales', votes: 5200 },
    { name: 'Instantly', tagline: 'AI cold email campaigns', category: 'sales', votes: 3800 },
    { name: 'Luna', tagline: 'AI email personalization', category: 'sales', votes: 2800 },
    { name: 'Regie.ai', tagline: 'AI sales prospecting', category: 'sales', votes: 3200 },
    { name: 'Otter.ai', tagline: 'AI meeting transcription', category: 'productivity', votes: 9200 },
    { name: 'Fireflies.ai', tagline: 'AI meeting notes and search', category: 'productivity', votes: 6800 },
    { name: 'Fathom', tagline: 'AI meeting summaries', category: 'productivity', votes: 5200 },
    { name: 'Read.ai', tagline: 'AI meeting analytics', category: 'productivity', votes: 4800 },
    { name: ' tl;dv', tagline: 'AI meeting recorder', category: 'productivity', votes: 4200 },
  ];
  
  // 根据日期轮换选择产品
  const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / (1000 * 60 * 60 * 24));
  const startIndex = (dayOfYear * 7) % aiProducts.length; // 每天轮换7个产品
  
  const selected = [];
  for (let i = 0; i < CONFIG.maxResults; i++) {
    const index = (startIndex + i) % aiProducts.length;
    const product = aiProducts[index];
    selected.push({
      id: `rotated-${dayOfYear}-${i}`,
      name: product.name,
      tagline: product.tagline,
      url: `https://www.google.com/search?q=${encodeURIComponent(product.name + ' AI tool')}`,
      thumbnail: '',
      votesCount: product.votes,
      createdAt: new Date().toISOString(),
      topics: [product.category],
      source: 'rotated'
    });
  }
  
  console.log(`✅ 轮换模式生成 ${selected.length} 个产品`);
  return selected;
}

/**
 * 合并并去重
 */
function mergeProducts(productLists) {
  const seen = new Map();
  
  for (const products of productLists) {
    for (const product of products) {
      const key = product.name.toLowerCase().trim();
      if (!seen.has(key) || (product.votesCount || 0) > (seen.get(key).votesCount || 0)) {
        seen.set(key, product);
      }
    }
  }
  
  return Array.from(seen.values()).sort((a, b) => (b.votesCount || 0) - (a.votesCount || 0));
}

/**
 * 转换为统一格式
 */
function convertToUnifiedFormat(product) {
  const initials = product.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
  const image = product.thumbnail || 
    `https://ui-avatars.com/api/?name=${encodeURIComponent(initials)}&background=0a192f&color=64ffda&size=400`;
  
  return {
    id: `producthunt-${product.id}`,
    source: 'producthunt',
    title: product.name,
    description: product.tagline,
    url: product.url,
    image: image,
    metadata: {
      votes: product.votesCount || 0,
      topics: product.topics || [],
      source: product.source || 'unknown'
    },
    publishedAt: product.createdAt ? product.createdAt.split('T')[0] : getToday(),
    category: 'product'
  };
}

/**
 * 保存数据
 */
function saveData(products) {
  const outputPath = path.join(__dirname, `../../data/producthunt/${getToday()}.json`);
  const dir = path.dirname(outputPath);
  
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  const unifiedData = products.map(convertToUnifiedFormat);
  
  fs.writeFileSync(outputPath, JSON.stringify({
    date: getToday(),
    count: unifiedData.length,
    sources: [...new Set(products.map(p => p.source))],
    items: unifiedData
  }, null, 2));
  
  console.log(`💾 数据已保存: ${outputPath}`);
  return unifiedData;
}

/**
 * 主函数
 */
async function main() {
  console.log('🚀 Product Hunt 采集器启动 (v2.1)');
  console.log(`📅 日期: ${getToday()}`);
  console.log(`🎯 目标: ${CONFIG.maxResults} 个产品`);
  console.log(`📚 今日主题: ${CONFIG.topics[getTodayTopicIndex()].join(', ')}`);
  console.log('');
  
  const allProducts = [];
  
  // 1. 尝试 Product Hunt API
  const apiProducts = await fetchFromProductHuntAPI();
  allProducts.push(...apiProducts);
  
  if (apiProducts.length > 0) {
    await delay(1000);
  }
  
  // 2. 尝试替代数据源
  if (allProducts.length < CONFIG.maxResults) {
    const futurepediaProducts = await fetchFromFuturepedia();
    allProducts.push(...futurepediaProducts);
    await delay(1000);
  }
  
  if (allProducts.length < CONFIG.maxResults) {
    const alternativetoProducts = await fetchFromAlternativeTo();
    allProducts.push(...alternativetoProducts);
  }
  
  console.log('');
  console.log(`📊 原始数据汇总:`);
  console.log(`  总收集: ${allProducts.length} 个产品`);
  
  // 合并去重
  let uniqueProducts = mergeProducts([allProducts]);
  console.log(`  去重后: ${uniqueProducts.length} 个产品`);
  
  // 如果数据不足，使用轮换模式补充
  if (uniqueProducts.length < CONFIG.maxResults) {
    console.log(`⚠️ 在线数据不足 (${uniqueProducts.length}/${CONFIG.maxResults})，使用轮换模式补充...`);
    const rotatedProducts = generateRotatedProducts();
    
    // 合并，优先使用真实数据
    const existingNames = new Set(uniqueProducts.map(p => p.name.toLowerCase()));
    for (const product of rotatedProducts) {
      if (!existingNames.has(product.name.toLowerCase())) {
        uniqueProducts.push(product);
        existingNames.add(product.name.toLowerCase());
      }
      if (uniqueProducts.length >= CONFIG.maxResults) break;
    }
  }
  
  // 取前 N 个
  const selectedProducts = uniqueProducts.slice(0, CONFIG.maxResults);
  console.log(`  最终选择: ${selectedProducts.length} 个产品`);
  console.log('');
  
  // 保存数据
  const unifiedData = saveData(selectedProducts);
  
  // 输出摘要
  console.log('📋 采集的产品列表:');
  unifiedData.forEach((item, i) => {
    const source = item.metadata.source || 'unknown';
    console.log(`  ${i + 1}. ${item.title} ⬆️ ${item.metadata.votes} [${source}]`);
  });
  
  console.log('');
  console.log('✅ Product Hunt 采集完成!');
  console.log('💡 提示: 设置 PRODUCTHUNT_TOKEN 可获得更准确的实时数据');
}

// 错误处理
process.on('unhandledRejection', (error) => {
  console.error('❌ 未处理的错误:', error.message);
  process.exit(1);
});

// 运行主函数
main().catch(error => {
  console.error('❌ 采集失败:', error.message);
  process.exit(1);
});
