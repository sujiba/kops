function envoy_on_request(request_handle)
  local ua = request_handle:headers():get("user-agent") or ""
  local ua_lower = string.lower(ua)

  local ai_crawlers = {
    -- OpenAI
    "gptbot", "oai-searchbot", "chatgpt-user", "chatgpt agent", "openai",
    "operator",
    -- Anthropic
    "claudebot", "claude-web", "claude-searchbot", "claude-user",
    "anthropic-ai", "claude-code",
    -- Google
    "google-extended", "googleother", "google-safety",
    "google-cloudvertexbot", "cloudvertexbot", "google-firebase",
    "google-notebooklm", "notebooklm", "gemini-deep-research",
    "googleagent-mariner", "google-agent", "google-gemini-cli",
    -- Meta
    "meta-externalagent", "meta-externalfetcher", "meta-webindexer",
    "facebookbot", "facebookexternalhit",
    -- Amazon
    "amazonbot", "amazon-kendra", "bedrockbot", "amzn-searchbot",
    "amzn-user", "amazonbuyforme", "novaact",
    -- Apple
    "applebot-extended", "applebot",
    -- ByteDance
    "bytespider", "tiktokspider",
    -- Perplexity
    "perplexitybot", "perplexity-user",
    -- Common Crawl
    "ccbot",
    -- Cohere
    "cohere-ai", "cohere-training-data-crawler",
    -- You.com
    "youbot",
    -- Diffbot
    "diffbot",
    -- Allen Institute
    "ai2bot", "ai2bot-dolma", "ai2bot-deepresearcheval",
    -- Hive AI
    "imagesiftbot",
    -- Webz.io
    "omgili", "omgilibot", "webzio-extended",
    -- Timpi
    "timpibot",
    -- DuckDuckGo AI
    "duckassistbot",
    -- Huawei
    "pangubot", "petalbot",
    -- Mistral
    "mistralai-user",
    -- DeepSeek
    "deepseekbot",
    -- Yandex AI
    "yandexadditional", "yandexadditionalbot",
    -- Semrush
    "semrushbot-ocob", "semrushbot-swa",
    -- Misc AI scrapers / data providers
    "brightbot", "friendlycrawler", "velenpublicwebcrawler",
    "iaskspider", "kangaroo bot", "firecrawlagent", "crawl4ai",
    "apifybot", "apifywebsitecontentcrawler", "scrapy",
    "diffbot", "laiondownloader", "img2dataset",
    "sidetrade indexer bot", "factset_spyderbot",
    "aihitbot", "anomura", "andibot", "bravebot",
    "bigsur.ai", "phindbot", "tavilybot", "linerbot",
    "atlassian-bot", "sbintuitionsbot", "cotoyogi",
    "icccrawler", "icc-crawler", "isscybercrawler",
    "terracotta", "terra cotta", "thinkbot",
    "shapbot", "shap-user", "qualifiedbot", "quillbot",
    "linguee bot", "linkupbot", "exabot",
    "wardbot", "wrtnbot", "zanistabot", "channel3bot",
    "chatglm-spider", "devin", "manus-user",
    "twinagent", "trae", "opencode",
    "yak", "awario", "echoboxbot",
    "nagetbot", "kunatocrawler",
    "poseidon research crawler",
    "datenbank crawler",
  }

  for _, bot in ipairs(ai_crawlers) do
    if string.find(ua_lower, bot, 1, true) then
      request_handle:respond({[":status"] = "200"}, "")
      return
    end
  end
end

function envoy_on_response(response_handle)
end
