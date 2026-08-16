# directory.topics

Required on every config. Vocabulary SSOT: `Html2rss::Config::Validator::DIRECTORY_TOPICS` (also listed in [AGENTS.md](../../../../AGENTS.md)).

Prefer **1–2** primary topics. Do not invent strings.

## Vocabulary

`sports`, `energy`, `tech`, `science`, `news`, `entertainment`, `jobs`, `finance`, `security`, `travel`, `environment`, `consumer`, `civic`, `product`, `research`

## Quick mapping

| Surface                            | Typical topics                            |
| ---------------------------------- | ----------------------------------------- |
| AI / eng blog, OSS release notes   | `tech` + `research` or `tech` + `product` |
| Company product newsroom           | `tech` + `product`                        |
| Security advisories / cyber agency | `security` (+ `tech` or `civic`)          |
| Gov / IGO / regulator press        | `civic`                                   |
| Think tank analysis                | `civic` + `research`                      |
| Science institute / lab            | `science` + `research`                    |
| Space agency                       | `science` + `research`                    |
| General newsroom                   | `news`                                    |
| Investigative / OSINT newsroom     | `news` + `civic`                          |
| Energy / climate agency            | `energy` + `environment`                  |
| Markets / central bank / IMF-class | `finance` + `civic`                       |
| Patents / IP office                | `civic` + `tech`                          |
| Courts / legal press               | `civic`                                   |
| Aviation / shipping regulator      | `civic`                                   |
| Telecom / spectrum regulator       | `civic` + `tech`                          |
| Semiconductors / hardware vendor   | `tech` + `product`                        |
| Food / agriculture agency          | `environment` + `civic`                   |
| Jobs board                         | `jobs`                                    |
| Consumer tests / recalls           | `consumer` (+ `civic`)                    |
| Travel / local visitor news        | `travel` (+ `news`)                       |
| Sports                             | `sports`                                  |
| Film / games / music               | `entertainment`                           |

Ambiguous hybrid: pick audience intent, not every plausible tag.
