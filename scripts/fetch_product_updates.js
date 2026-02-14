// scripts/fetch_product_updates.js
const https = require('https');
const { URL } = require('url');

const SOURCES = [
    // OpenAI: Try news RSS or blog RSS
    { name: 'OpenAI', urls: ['https://openai.com/news/rss.xml', 'https://openai.com/blog/rss.xml'] },
    // Anthropic: Try feed or rss.xml
    { name: 'Anthropic', urls: ['https://www.anthropic.com/feed', 'https://www.anthropic.com/rss.xml', 'https://www.anthropic.com/index.xml'] },
    { name: 'Google AI', urls: ['https://blog.google/technology/ai/rss/'] },
    { name: 'Product Hunt', urls: ['https://www.producthunt.com/feed?category=artificial-intelligence'] }
];

// Simple RSS Parser using Regex
function parseRSS(xml, sourceName) {
    const items = [];
    const cleanXML = xml.replace(/<(\/?)([^:>\s]+:)?([^>]+)>/g, "<$1$3>"); 

    const itemRegex = /<item>([\s\S]*?)<\/item>|<entry>([\s\S]*?)<\/entry>/g;
    let match;
    
    while ((match = itemRegex.exec(cleanXML)) !== null) {
        const content = match[1] || match[2];
        
        let title = "No Title";
        const titleMatch = content.match(/<title[^>]*>([\s\S]*?)<\/title>/);
        if (titleMatch) title = titleMatch[1].replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1').trim();

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
                title: title.replace(/&amp;/g, '&').replace(/&#x27;/g, "'"),
                link: link,
                date: date
            });
        }
    }
    return items.slice(0, 5); 
}

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

async function fetchSource(source) {
    for (const url of source.urls) {
        try {
            console.log(`Fetching ${source.name} from ${url}...`);
            const xml = await fetchURL(url);
            const items = parseRSS(xml, source.name);
            if (items.length > 0) return items;
        } catch (e) {
            console.error(`Failed ${url}: ${e.message}`);
        }
    }
    return [];
}

(async () => {
    console.log("Starting update check...");
    const allUpdates = [];

    for (const source of SOURCES) {
        const items = await fetchSource(source);
        if (items.length > 0) {
            console.log(`✅ ${source.name}: Found ${items.length} items`);
            allUpdates.push(...items);
        } else {
            console.log(`❌ ${source.name}: No items found`);
        }
    }

    console.log("\n--- JSON OUTPUT ---");
    console.log(JSON.stringify(allUpdates, null, 2));
})();
