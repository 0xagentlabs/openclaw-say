#!/usr/bin/env node

/**
 * 数据合并脚本
 * 将 GitHub、YouTube、Product Hunt 的数据合并为统一格式
 */

const fs = require('fs');
const path = require('path');

/**
 * 获取今天的日期字符串
 */
function getToday() {
  return new Date().toISOString().split('T')[0];
}

/**
 * 读取数据源文件
 */
function readDataSource(sourceName, date) {
  const filePath = path.join(__dirname, `../../data/${sourceName}/${date}.json`);
  
  try {
    if (fs.existsSync(filePath)) {
      const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      console.log(`✅ ${sourceName}: ${data.count || 0} 条数据`);
      return data.items || [];
    } else {
      console.warn(`⚠️ ${sourceName}: 数据文件不存在 (${filePath})`);
      return [];
    }
  } catch (error) {
    console.error(`❌ ${sourceName}: 读取失败 - ${error.message}`);
    return [];
  }
}

/**
 * 合并所有数据源
 */
function mergeAllData(date) {
  console.log(`\n📅 合并日期: ${date}`);
  console.log('='.repeat(50));
  
  // 读取所有数据源
  const githubItems = readDataSource('github', date);
  const youtubeItems = readDataSource('youtube', date);
  const producthuntItems = readDataSource('producthunt', date);
  
  // 合并数据
  const allItems = [
    ...githubItems,
    ...youtubeItems,
    ...producthuntItems
  ];
  
  console.log('='.repeat(50));
  console.log(`📊 总计: ${allItems.length} 条数据`);
  
  // 按发布时间排序（最新的在前）
  allItems.sort((a, b) => {
    const dateA = new Date(a.publishedAt || '1970-01-01');
    const dateB = new Date(b.publishedAt || '1970-01-01');
    return dateB - dateA;
  });
  
  return {
    date: date,
    generatedAt: new Date().toISOString(),
    summary: {
      total: allItems.length,
      github: githubItems.length,
      youtube: youtubeItems.length,
      producthunt: producthuntItems.length
    },
    items: allItems
  };
}

/**
 * 生成统计信息
 */
function generateStats(data) {
  const stats = {
    categories: {},
    sources: {}
  };
  
  data.items.forEach(item => {
    // 统计分类
    if (item.category) {
      stats.categories[item.category] = (stats.categories[item.category] || 0) + 1;
    }
    
    // 统计来源
    if (item.source) {
      stats.sources[item.source] = (stats.sources[item.source] || 0) + 1;
    }
  });
  
  return stats;
}

/**
 * 主函数
 */
async function main() {
  try {
    const targetDate = process.argv[2] || getToday();
    
    console.log('🚀 数据合并器启动');
    console.log(`📅 目标日期: ${targetDate}`);
    
    // 合并数据
    const mergedData = mergeAllData(targetDate);
    
    if (mergedData.items.length === 0) {
      console.warn('⚠️ 没有数据可合并');
      process.exit(0);
    }
    
    // 生成统计
    mergedData.stats = generateStats(mergedData);
    
    // 保存合并后的数据
    const outputPath = path.join(__dirname, `../../data/combined/${targetDate}.json`);
    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    fs.writeFileSync(outputPath, JSON.stringify(mergedData, null, 2));
    
    console.log(`\n💾 合并数据已保存: ${outputPath}`);
    
    // 输出统计
    console.log('\n📊 数据统计:');
    console.log(`  总计: ${mergedData.summary.total}`);
    console.log(`  GitHub: ${mergedData.summary.github}`);
    console.log(`  YouTube: ${mergedData.summary.youtube}`);
    console.log(`  Product Hunt: ${mergedData.summary.producthunt}`);
    
    console.log('\n📁 分类统计:');
    Object.entries(mergedData.stats.categories).forEach(([cat, count]) => {
      console.log(`  ${cat}: ${count}`);
    });
    
    console.log('\n✅ 数据合并完成!');
    
    // 同时生成一个 latest.json 用于前端快速访问
    const latestPath = path.join(__dirname, `../../data/combined/latest.json`);
    fs.writeFileSync(latestPath, JSON.stringify(mergedData, null, 2));
    console.log(`💾 最新数据已同步: ${latestPath}`);
    
  } catch (error) {
    console.error('❌ 合并失败:', error.message);
    process.exit(1);
  }
}

// 运行主函数
main();
