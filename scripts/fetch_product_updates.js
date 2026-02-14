// scripts/fetch_product_updates.js
const https = require('https');
const fs = require('fs');
const path = require('path');

const SOURCES = [
    { name: 'OpenAI', urls: ['https://openai.com/news/rss.xml', 'https://openai.com/blog/rss.xml'] },
    { name: 'Google AI', urls: ['https://blog.google/technology/ai/rss/'] },
    { name: 'Product Hunt', urls: ['https://www.producthunt.com/feed?category=artificial-intelligence'] }
];

function fetchURL(url) {
    return new Promise((resolve, reject) => {
        const req = https.get(url, (res) => {
            if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
                return fetchURL(res.headers.location).then(resolve).catch(reject);
            }
            if (res.statusCode >= 400) {
                 return reject(new Error(`Status ${res.statusCode}`));
            }
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(data));
        });
        req.on('error', reject);
    });
}

function parseRSS(xml, sourceName) {
    const items = [];
    const cleanXML = xml.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1'); 
    const itemRegex = /<item>([\s\S]*?)<\/item>|<entry>([\s\S]*?)<\/entry>/g;
    let match;
    
    while ((match = itemRegex.exec(cleanXML)) !== null) {
        const content = match[1] || match[2];
        let title = "No Title";
        const titleMatch = content.match(/<title[^>]*>([\s\S]*?)<\/title>/);
        if (titleMatch) title = titleMatch[1].trim();

        let link = "";
        const linkMatch = content.match(/<link[^>]*>([^<]+)<\/link>/);
        const linkHrefMatch = content.match(/<link[^>]*href="([^"]+)"/);
        if (linkMatch) link = linkMatch[1].trim();
        else if (linkHrefMatch) link = linkHrefMatch[1].trim();

        let date = "";
        const dateMatch = content.match(/<pubDate>([^<]+)<\/pubDate>/);
        const updatedMatch = content.match(/<updated>([^<]+)<\/updated>/);
        if (dateMatch) date = dateMatch[1];
        else if (updatedMatch) date = updatedMatch[1];

        if (title !== "No Title") {
            items.push({
                source: sourceName,
                title: title.replace(/&amp;/g, '&').replace(/&#x27;/g, "'").replace(/&#39;/g, "'"),
                link: link,
                date: date
            });
        }
    }
    return items.slice(0, 5); 
}

// Custom Anthropic Fetcher (Scrapes Next.js data)
async function fetchAnthropic() {
    console.log("Fetching Anthropic news...");
    try {
        const html = await fetchURL('https://www.anthropic.com/news');
        const items = [];
        
        // Regex to capture date, slug, and title from the escaped JSON in Next.js hydration data
        // Looks for: \"publishedOn\":\"...\",\"slug\":{\"_type\":\"slug\",\"current\":\"...\"},...,\"title\":\"...\"
        // Note: We match loosely to be robust against field ordering changes
        const postRegex = /\\"publishedOn\\":\\"(.*?)\\",.*?\\"slug\\":\{.*?\\"current\\":\\"(.*?)\\"\},.*?\\"title\\":\\"(.*?)\\"/g;
        
        let match;
        while ((match = postRegex.exec(html)) !== null) {
            const date = match[1];
            const slug = match[2];
            const title = match[3];
            
            // Basic dedupe based on title
            if (!items.find(i => i.title === title)) {
                 items.push({
                    source: 'Anthropic',
                    title: title,
                    link: `https://www.anthropic.com/news/${slug}`,
                    date: date
                });
            }
        }
        
        // Sort descending
        items.sort((a, b) => new Date(b.date) - new Date(a.date));
        return items.slice(0, 5);
    } catch (e) {
        console.error(`Failed to fetch Anthropic: ${e.message}`);
        return [];
    }
}

function generateMarkdown(updates) {
    let md = "## 📢 AI Product Updates\n\n";
    const grouped = {};
    
    // Highlight DeepSeek mentions
    const deepSeekItems = updates.filter(u => u.title.toLowerCase().includes('deepseek'));
    if (deepSeekItems.length > 0) {
        md += "### 🚨 DeepSeek Mentions\n";
        deepSeekItems.forEach(item => {
             md += `- [${item.title}](${item.link}) - _${item.source}_\n`;
        });
        md += "\n";
    }

    updates.forEach(u => {
        if (!grouped[u.source]) grouped[u.source] = [];
        grouped[u.source].push(u);
    });

    for (const source in grouped) {
        md += `### ${source}\n`;
        grouped[source].forEach(item => {
            md += `- [${item.title}](${item.link}) - _${item.date}_\n`;
        });
        md += "\n";
    }
    return md;
}

function generateHTML(updates) {
    let html = '<div class="product-updates-section" style="margin: 40px 0; background: white; padding: 30px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">';
    html += '<h2 style="color: #2d3436; border-bottom: 2px solid #eee; padding-bottom: 15px; margin-bottom: 25px;"><i class="fas fa-newspaper"></i> 行业动态 & 新品发布</h2>';
    
    const grouped = {};
    
    // DeepSeek
    const deepSeekItems = updates.filter(u => u.title.toLowerCase().includes('deepseek'));
    if (deepSeekItems.length > 0) {
        html += '<div style="background: #fff3cd; padding: 15px; border-radius: 10px; margin-bottom: 20px; border-left: 5px solid #ffc107;">';
        html += '<h3 style="color: #856404; margin-top: 0;"><i class="fas fa-fire"></i> DeepSeek 动态</h3><ul style="list-style: none; padding-left: 0;">';
        deepSeekItems.forEach(item => {
             html += `<li style="margin-bottom: 10px;"><a href="${item.link}" target="_blank" style="color: #2d3436; text-decoration: none; font-weight: 500;">${item.title}</a> <span style="color: #666; font-size: 0.9em;">- ${item.source}</span></li>`;
        });
        html += '</ul></div>';
    }

    updates.forEach(u => {
        if (!grouped[u.source]) grouped[u.source] = [];
        grouped[u.source].push(u);
    });

    html += '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">';

    for (const source in grouped) {
        html += `<div class="source-column">`;
        html += `<h3 style="color: #0984e3; border-left: 4px solid #0984e3; padding-left: 10px;">${source}</h3>`;
        html += '<ul style="padding-left: 20px;">';
        grouped[source].forEach(item => {
            html += `<li style="margin-bottom: 8px;"><a href="${item.link}" target="_blank" style="color: #444; text-decoration: none;">${item.title}</a> <span style="color: #999; font-size: 0.8em;">(${new Date(item.date).toLocaleDateString()})</span></li>`;
        });
        html += '</ul></div>';
    }
    
    html += '</div></div>';
    return html;
}

(async () => {
    console.log("Starting update check...");
    const allUpdates = [];

    // RSS Sources
    for (const source of SOURCES) {
        try {
            for (const url of source.urls) {
                console.log(`Fetching ${source.name} from ${url}...`);
                const xml = await fetchURL(url);
                const items = parseRSS(xml, source.name);
                if (items.length > 0) {
                    allUpdates.push(...items);
                    break; // Use first working URL for source
                }
            }
        } catch (e) {
            console.error(`Error fetching ${source.name}: ${e.message}`);
        }
    }

    // Custom Sources
    const anthropicItems = await fetchAnthropic();
    if (anthropicItems.length > 0) allUpdates.push(...anthropicItems);

    console.log(`Total items found: ${allUpdates.length}`);

    const md = generateMarkdown(allUpdates);
    const mdPath = path.join(__dirname, '../product_updates.md');
    fs.writeFileSync(mdPath, md);
    
    const html = generateHTML(allUpdates);
    const htmlPath = path.join(__dirname, '../product_updates.html');
    fs.writeFileSync(htmlPath, html);

    console.log(`\nReports saved to ${mdPath} and ${htmlPath}`);
})();
