# 什麼可以停掉？

定期問這個問題。隨著 Model 能力提升，過去的 workaround 可能變成拖慢速度的垃圾。

## 真實案例

**Sonnet 4.5 → Opus 4.5**

問題：Sonnet 4.5 在 context 快滿的時候會焦慮，開發者加了「提前結束」的機制。

後來升級到 Opus 4.5，問題自動消失了。那些「提前結束」的機制，變成多餘的 code，反而拖慢效能。

**結論**：Model 會變強，過去打的补丁可能沒用了，要定期刪掉。

## 什麼東西該停掉？

| 類型 | 跡象 |
|------|------|
| Workaround | 當初是為了繞過某個 model 的限制，但現在已經不存在了 |
| Safety check | 現在 model 已經內建這個能力了 |
| Extra confirmation | model 已經會自己問了 |
| Over-engineered structure | 當初擔心某個問題，現在 model 已經不會犯了 |

## 怎麼發現該停掉的東西？

1. 觀察 model 的行為 — 是不是有某個 pattern 一直讓你覺得「為什麼要多這一步？」
2. 定期 review harness code — 問「這個假設還成立嗎？」
3. 升級 model 後觀察 — 之前加的 workaround 是不是變成累贅了

## 一句話

> 不要因為害怕，就加一堆 safety。Model 會越來越強，該刪就刪。
