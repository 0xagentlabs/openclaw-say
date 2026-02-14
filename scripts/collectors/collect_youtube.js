#!/usr/bin/env node

/**
 * YouTube AI 视频采集脚本
 * 从指定频道的 RSS feed 获取最新视频
 * 支持错误处理和优雅降级
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// 频道配置
const CHANNELS = [
  {
    id: 'UCbfYPyITQ-7l4upoX8nvctg',
    name: 'Two Minute Papers',
    rssUrl: 'https://www.youtube.com/feeds/videos.xml?channel_id=UCbfYPyITQ-7l4upoX8nvctg',
    description: '用最短的时间了解最前沿的 AI 研究'
  },
  {
    id: 'UCuK2Mf5As9OKfWU7XV6yzCg',
    name: 'Matt Wolfe',
    rssUrl: 'https://www.youtube.com/feeds/videos.xml?channel_id=UCuK2Mf5As9OKfWU7XV6yzCg',
    description: 'AI 工具评测和技术趋势分析'
  }
];

// 备用视频列表（当 RSS 不可用时使用）
const FALLBACK_VIDEOS = [
  {
    id: 'fallback-1',
    title: 'AI Explained',
    description: '深入解析最新 AI 技术和研究进展',
    url: 'https://www.youtube.com/@aiexplained-official',
    channel: 'AI Explained',
    image: 'https://img.youtube.com/vi/placeholder/maxresdefault.jpg',
    publishedAt: new Date().toISOString()
  },
  {
    id: 'fallback-2',
    title: 'Two Minute Papers',
    description: '每日 AI 研究论文精华',
    url: 'https://www.youtube.com/@TwoMinutePapers',
    channel: 'Two Minute Papers',
    image: 'https://img.youtube.com/vi/placeholder/maxresdefault.jpg',
    publishedAt: new Date().toISOString()
  },
  {
    id: 'fallback-3',
    title: 'Matt Wolfe',
    description: 'AI 工具和创意应用探索',
    url: 'https://www.youtube.com/@mreflow',
    channel: 'Matt Wolfe',
    image: 'https://img.youtube.com/vi/placeholder/maxresdefault.jpg',
    publishedAt: new Date().toISOString()
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
function fetchXML(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, {
      headers: {
        'Accept': 'application/xml, text/xml, */*',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      },
      timeout: 15000
    }, (res) => {
      // 处理重定向
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        console.log(`🔄 重定向到: ${res.headers.location}`);
        return fetchXML(res.headers.location).then(resolve).catch(reject);
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
 * 从 YouTube 视频 URL 提取视频 ID
 */
function extractVideoId(url) {
  const match = url.match(/[?&]v=([^&]+)/);
  return match ? match[1] : null;
}

/**
 * 解析 RSS XML
 */
function parseRSS(xml, channelInfo) {
  const items = [];
  
  // 提取 entry 节点（YouTube RSS 格式）
  const entryRegex = /<entry[^>]*>([\s\S]*?)<\/entry>/g;
  let match;
  
  while ((match = entryRegex.exec(xml)) !== null) {
    const entry = match[1];
    
    // 提取标题
    const titleMatch = entry.match(/<title[^>]*>([\s\S]*?)<\/title>/);
    const title = titleMatch ? titleMatch[1].trim() : 'Unknown Title';
    
    // 提取视频链接
    const linkMatch = entry.match(/<link[^>]*rel="alternate"[^>]*href="([^"]+)"/);
    const link = linkMatch ? linkMatch[1] : '';
    const videoId = extractVideoId(link);
    
    // 提取发布时间
    const publishedMatch = entry.match(/<published>([^<]+)<\/published>/);
    const publishedAt = publishedMatch ? publishedMatch[1] : new Date().toISOString();
    
    // 提取媒体描述
    const mediaDescMatch = entry.match(/<media:description[^>]*>([\s\S]*?)<\/media:description>/);
    const description = mediaDescMatch ? mediaDescMatch[1].trim() : '';
    
    // 提取缩略图
    const thumbnailMatch = entry.match(/<media:thumbnail[^>]*url="([^"]+)"/);
    let thumbnail = thumbnailMatch ? thumbnailMatch[1] : '';
    
    // 如果没有 media:thumbnail，使用默认缩略图
    if (!thumbnail && videoId) {
      thumbnail = `https://img.youtube.com/vi/${videoId}/mqdefault.jpg`;
    }
    
    // 提取观看次数（如果 RSS 中有）
    const viewsMatch = entry.match(/<media:statistics[^>]*views="([^"]+)"/);
    const views = viewsMatch ? parseInt(viewsMatch[1]) : null;
    
    if (title && link) {
      items.push({
        id: videoId || `video-${Date.now()}-${items.length}`,
        title: title,
        description: description.substring(0, 200) + (description.length > 200 ? '...' : ''),
        url: link,
        image: thumbnail,
        channel: channelInfo.name,
        publishedAt: publishedAt,
        views: views
      });
    }
  }
  
  return items;
}

/**
 * 获取单个频道的视频
 */
async function fetchChannelVideos(channel) {
  console.log(`\n📺 采集频道: ${channel.name}`);
  console.log(`   RSS: ${channel.rssUrl}`);
  
  try {
    const xml = await fetchXML(channel.rssUrl);
    const videos = parseRSS(xml, channel);
    
    console.log(`✅ 成功获取 ${videos.length} 个视频`);
    return videos;
    
  } catch (error) {
    console.error(`❌ 获取失败: ${error.message}`);
    
    // 根据错误类型提供不同的备用方案
    if (error.message === 'RSS_FEED_NOT_FOUND') {
      console.log('⚠️ RSS Feed 不存在，使用备用视频列表');
      return getFallbackVideosForChannel(channel);
    } else if (error.message.includes('TIMEOUT')) {
      console.log('⏱️ 请求超时，使用备用视频列表');
      return getFallbackVideosForChannel(channel);
    } else {
      console.log('⚠️ 网络错误，使用备用视频列表');
      return getFallbackVideosForChannel(channel);
    }
  }
}

/**
 * 获取频道的备用视频
 */
function getFallbackVideosForChannel(channel) {
  // 返回该频道的备用视频或通用备用视频
  const fallback = FALLBACK_VIDEOS.find(v => v.channel === channel.name);
  if (fallback) {
    return [fallback];
  }
  
  // 返回通用备用视频
  return FALLBACK_VIDEOS.slice(0, 2).map(v => ({
    ...v,
    id: `${channel.id}-${v.id}`,
    channel: channel.name
  }));
}

/**
 * 转换为统一数据格式
 */
function convertToUnifiedFormat(video) {
  // 格式化观看次数
  let viewsFormatted = 'N/A';
  if (video.views) {
    if (video.views >= 1000000) {
      viewsFormatted = (video.views / 1000000).toFixed(1) + 'M';
    } else if (video.views >= 1000) {
      viewsFormatted = (video.views / 1000).toFixed(1) + 'K';
    } else {
      viewsFormatted = video.views.toString();
    }
  }
  
  return {
    id: `youtube-${video.id}`,
    source: 'youtube',
    title: video.title,
    description: video.description,
    url: video.url,
    image: video.image,
    metadata: {
      views: viewsFormatted,
      channel: video.channel,
      videoId: video.id
    },
    publishedAt: video.publishedAt.split('T')[0],
    category: 'video'
  };
}

/**
 * 主函数
 */
async function main() {
  console.log('🚀 YouTube 采集器启动');
  console.log(`📅 日期: ${getToday()}`);
  console.log(`📺 频道数量: ${CHANNELS.length}`);
  
  const allVideos = [];
  
  // 采集每个频道
  for (const channel of CHANNELS) {
    const videos = await fetchChannelVideos(channel);
    
    // 取最新的 5 个视频
    const recentVideos = videos.slice(0, 5);
    allVideos.push(...recentVideos);
  }
  
  console.log(`\n📊 总计获取 ${allVideos.length} 个视频`);
  
  // 转换为统一格式
  const unifiedData = allVideos.map(convertToUnifiedFormat);
  
  // 保存数据
  const outputPath = path.join(__dirname, `../../data/youtube/${getToday()}.json`);
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
  
  console.log('\n📋 采集的视频列表:');
  unifiedData.forEach((item, i) => {
    console.log(`  ${i + 1}. ${item.title} ▶️ ${item.metadata.views}`);
  });
  
  console.log('\n✅ YouTube 采集完成!');
}

// 运行主函数
main().catch(error => {
  console.error('❌ 采集失败:', error);
  process.exit(1);
});
