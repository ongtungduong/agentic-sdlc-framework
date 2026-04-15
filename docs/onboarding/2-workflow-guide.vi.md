# VSAF INSTRUCTION — Hướng dẫn vận dụng nâng cao

> **Đối tượng:** Dev mới join repo này VÀ lần đầu dùng Claude Code.
> **Mục tiêu:** Dạy bạn *vận dụng* 8 tool của VSAF phối hợp với nhau, không chỉ chạy command.
> **Bổ trợ cho:** [1-setup-guide.md](1-setup-guide.md) (install + tổng quan). Đọc file đó trước nếu chưa.
> **Xem thêm:** [README.md](../../README.md) (tổng quan dự án) · [3-cheatsheet.md](3-cheatsheet.md) (tra cứu nhanh) · [4-milestones.md](4-milestones.md) (lộ trình Day 1/Week 1/Month 1) · [5-faq.md](5-faq.md) (FAQ tư duy)

Tài liệu này trả lời 3 câu hỏi mà file overview không trả lời:
1. **Khi nào** tôi dùng tool nào? (không phải chỉ "nó làm gì")
2. **Làm sao** phối hợp các tool để chúng cộng hưởng với nhau?
3. **Một chu trình SDLC thật sự** trông ra sao, command từng bước?

---

## Mục lục

1. [Bắt đầu — 5 phút định hướng](#1-bắt-đầu)
2. [Deep Dive từng tool](#2-deep-dive-từng-tool)
3. [Playbook phối hợp](#3-playbook-phối-hợp)
4. [Demo SDLC toàn trình — JWT Refresh Token Rotation](#4-demo-sdlc-toàn-trình)
5. [Mẹo nâng cao](#5-mẹo-nâng-cao)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Bắt đầu

### Mental Model

Quên "AI autocomplete" đi. VSAF coi Claude Code như một thành viên team có kỷ luật, bắt buộc phải:

```
    SPEC  ─────►  PLAN  ─────►  TDD  ─────►  REVIEW 3 LỚP  ─────►  SHIP
    (cái gì)    (làm sao)    (code)     (methodology/spec/graph)
```

Mọi feature phải đi qua mọi giai đoạn. Bug fix được đi đường tắt (Quick Flow: bỏ spec, giữ plan + TDD + review). Không có gì được ship nếu Layer 2 (spec compliance) fail.

### 4 Layer và 8 Tool

| Layer | Tool | Việc của bạn |
|---|---|---|
| **Planning** | BMAD + OpenSpec | Biến ý tưởng thành spec có thể verify |
| **Code Intel** | GitNexus + Graphify | Biết cái gì sẽ hỏng trước khi bạn làm hỏng nó |
| **Memory** | claude-mem + MemPalace | Không bao giờ phải học lại cùng một thứ 2 lần |
| **Implementation** | Claude Code + Superpowers + ECC | Code có lan can bảo vệ |

### Bảng quyết định — "Dùng tool nào bây giờ?"

| Tình huống | Tool đầu tiên | Tại sao |
|---|---|---|
| "Tôi không hiểu codebase này" | Graphify (`GRAPH_REPORT.md`) | Tổng quan cấu trúc trong 1 file |
| "Cái gì sẽ hỏng nếu tôi sửa `X`?" | GitNexus (`gitnexus_impact`) | Blast radius dựa trên call-graph |
| "Tại sao hồi đó chọn `X` thay vì `Y`?" | MemPalace (`mempalace_search`) | Lịch sử quyết định lưu nguyên văn |
| "Hôm qua tôi đã làm gì?" | claude-mem (tự auto-inject) | Session recall, không cần config |
| "Tôi có ý tưởng mơ hồ" | BMAD (`*agent analyst`) | Biến ý tưởng thành requirement |
| "Có requirement rồi, cần spec" | OpenSpec (`/opsx:propose`) | Proposal → design → tasks |
| "Có spec rồi, cần plan" | Superpowers (`/superpowers:write-plan`) | Task list atomic có verification |
| "Có plan rồi, cần code" | Superpowers (`/superpowers:execute-plan`) | TDD cycle, 1 commit/task |
| "Xong rồi, check trước PR" | `make review` | Review 3 lớp |
| "Merge xong, giờ sao?" | `make archive` | Archive + re-index |

**Quy tắc vàng:** Nếu bạn đang gõ code mà chưa chạm vào *bất kỳ* tool nào ở bảng trên — DỪNG.

---

## 2. Deep Dive từng tool

Mỗi phần có cấu trúc 5 mục cố định: **Mục đích → Khi nào BẮT BUỘC → Command nâng cao → Anti-patterns → Phối hợp với**.

### 2.1 BMAD Method (Agent Planning)

**Mục đích:** Các AI persona mô phỏng đội agile thật — Analyst, PM, Architect, Product Owner, Dev, UX, Tech Writer — mỗi agent có task và output riêng.

**Bắt buộc dùng khi:**
- Bắt đầu feature lớn hơn bug fix.
- Requirement từ stakeholder mơ hồ hoặc xung đột.
- Cần PRD, architecture doc, hoặc sprint stories.

**Command nâng cao (ngoài `*agent analyst`):**

| Command | Mở khóa gì |
|---|---|
| `bmad-brainstorming` | Ideation có cấu trúc trước khi gọi analyst — ra danh sách ý tưởng + xếp hạng |
| `bmad-product-brief` | Brief 1 trang cho stakeholder trước khi làm PRD đầy đủ |
| `bmad-prfaq` | "Working Backwards" kiểu Amazon — tốt cho scope đang tranh cãi |
| `bmad-domain-research` | Đẩy research domain/industry cho sub-agent |
| `bmad-check-implementation-readiness` | Validate PRD + arch + UX + tests *cùng lúc* trước khi code |
| `bmad-review-edge-case-hunter` | Đi qua mọi nhánh để tìm edge case chưa test |
| `bmad-retrospective` | Review sau epic — feed lessons vào MemPalace |
| `bmad-correct-course` | Khi scope thay đổi giữa sprint, align lại artifact thay vì bỏ đi |

**Anti-patterns:**
- Gọi `*agent dev` để viết code trước khi PM/Architect xong. Agent dev giả định PRD và arch đã tồn tại.
- Dùng BMAD cho bug fix 1 dòng. Quick Flow bỏ qua BMAD hoàn toàn.
- Sửa output BMAD bằng tay mà không chạy lại `bmad-check-implementation-readiness` — artifact downstream sẽ bị stale.

**Phối hợp với:**
- Output BMAD (`docs/prd.md`, `docs/architecture.md`) là *input* cho OpenSpec `/opsx:propose`.
- Diagram của BMAD Architect feed vào Graphify — chạy `/graphify . --update` sau khi arch thay đổi.
- Lưu decision không hiển nhiên từ BMAD retrospective vào MemPalace qua `mempalace_add_drawer`.

---

### 2.2 OpenSpec (Spec-Driven Development)

**Mục đích:** Buộc mọi thay đổi đi qua proposal, design, và task list được verify tự động.

**Bắt buộc dùng khi:** Đụng vào code không nằm trong Quick Flow.

**Command nâng cao:**

| Command | Mở khóa gì |
|---|---|
| `/opsx:explore` | Thinking partner *trước* khi propose — scratchpad, chưa commit artifact |
| `/opsx:propose <name>` | Tạo `openspec/changes/<name>/` với proposal, design, tasks |
| `/opsx:apply` | Implement task list (thường delegate cho Superpowers) |
| `/opsx:archive` | Chuyển change đã approve vào `openspec/specs/` — kho spec chính thức |
| `openspec validate --all` | Layer 2 của review 3 lớp |
| `openspec list` | Xem mọi change đang active — chạy trong `make status` |

**Anti-patterns:**
- Viết code mà chưa có proposal. Proposal *không* phải overhead — nó là contract mà Layer 2 verify ngược lại.
- Archive trước khi PR merge. Archive *sau* khi merge, trong `make archive`.
- Bỏ `/opsx:explore` cho scope phức tạp. Explore là suy nghĩ miễn phí; propose là cam kết.

**Phối hợp với:**
- Nội dung proposal được BMAD agent soạn trước, sau đó `/opsx:propose` chính thức hóa.
- Mỗi task trong task list nên qua 1 lần GitNexus impact check trước khi execute.
- Superpowers `write-plan` đọc OpenSpec tasks và mở rộng thành các bước TDD atomic.
- `make verify` (Layer 2) chạy `openspec validate --all`. Fail ở đây nghĩa là: **dừng, sửa, đừng push.**

---

### 2.3 Superpowers (Methodology Engine)

**Mục đích:** Thư viện skill áp đặt kỷ luật kỹ thuật — brainstorm, plan, TDD, code review, debug — qua Skill tool của Claude Code.

**Bắt buộc dùng khi:** Mọi implementation task. Luôn luôn.

**Command nâng cao (ngoài brainstorm/write-plan/execute-plan):**

| Skill | Dùng khi |
|---|---|
| `superpowers:systematic-debugging` | Đụng cùng bug 2 lần — bắt buộc hypothesis → experiment → conclusion |
| `superpowers:test-driven-development` | Enforce red-green-refactor; execute-plan gọi nhưng có thể dùng standalone |
| `superpowers:subagent-driven-development` | Plan dài — dispatch task cho sub-agent chạy song song |
| `superpowers:dispatching-parallel-agents` | 2+ task độc lập (vd: "research 3 thư viện", "audit 4 file") |
| `superpowers:verification-before-completion` | Trước khi claim task xong — bắt buộc verification step rõ ràng |
| `superpowers:requesting-code-review` | Khi task xong — handoff có cấu trúc cho code-reviewer |
| `superpowers:receiving-code-review` | Khi reviewer phản hồi — buộc response có hệ thống |
| `superpowers:using-git-worktrees` | Feature branch song song không làm bẩn main worktree |
| `superpowers:finishing-a-development-branch` | Checklist pre-PR — chạy review, verify, index, scan |

**Anti-patterns:**
- Bỏ `brainstorm` "vì task đơn giản." Task đơn giản là nơi assumption chưa kiểm chứng gây lãng phí nhiều nhất.
- Approve plan có task không có verification step. Không verify được thì không mark done được.
- Chạy `execute-plan` mà chưa có plan viết sẵn. Nó sẽ từ chối — viết plan trước.
- Bỏ qua RED step fail. RED phải fail đúng lý do trước khi bạn viết code.

**Phối hợp với:**
- `write-plan` tiêu thụ OpenSpec task; `execute-plan` tạo 1 commit/task kích hoạt ECC hook và (qua PostToolUse) re-index GitNexus.
- `systematic-debugging` kết hợp với GitNexus `query` + `context` — skill nói bạn *cách* điều tra, GitNexus nói bạn *chỗ* để nhìn.
- `code-review` (Layer 1) chạy trước `make verify` (Layer 2) chạy trước `make index` (Layer 3).

---

### 2.4 GitNexus (Code Intelligence MCP)

**Mục đích:** Kiến thức code dựa trên call-graph qua MCP tools. Trả lời câu hỏi impact, context, rename *không cần grep.*

**Bắt buộc dùng khi:** Trước khi sửa bất kỳ function/class/method nào. Không thương lượng — xem `AGENTS.md`.

**Command nâng cao:**

| Tool | Ví dụ | Đánh bại |
|---|---|---|
| `gitnexus_query` | `{query: "token refresh"}` | grep trên 50k LOC |
| `gitnexus_context` | `{name: "validateUser"}` | đọc từng caller bằng tay |
| `gitnexus_impact` | `{target: "X", direction: "upstream"}` | đoán cái gì sẽ hỏng |
| `gitnexus_detect_changes` | `{scope: "staged"}` | "mình có đụng nhiều hơn mình nghĩ không?" |
| `gitnexus_rename` | `{symbol_name: "old", new_name: "new", dry_run: true}` | find-and-replace nguy hiểm |
| `gitnexus_cypher` | `{query: "MATCH (f:Function)-[:CALLS]->(g) WHERE ..."}` | custom call-graph query |

**Mức độ rủi ro:**

| Depth | Ý nghĩa | Quy tắc |
|---|---|---|
| d=1 | CHẮC CHẮN HỎNG caller trực tiếp | PHẢI update chúng cùng PR |
| d=2 | CÓ KHẢ NĂNG ảnh hưởng gián tiếp | Phải test |
| d=3 | CÓ THỂ CẦN TEST | Test nếu critical path |

**Anti-patterns:**
- Rename bằng find-and-replace. Dùng `gitnexus_rename` — nó hiểu call graph.
- Bỏ qua warning HIGH/CRITICAL. Báo cho user trước khi tiếp tục.
- Quên `--embeddings` khi re-index nếu index từng có embeddings. Chúng bị *xóa* âm thầm.
- Commit mà không `gitnexus_detect_changes` — bạn có thể ship file mà mình không định.

**Phối hợp với:**
- Impact analysis *trước* Superpowers `write-plan` — plan của bạn phải cover d=1 caller.
- `detect_changes` *trước* mọi commit trong `execute-plan`.
- MCP resources (`gitnexus://repo/vsaf/process/<name>`) cho trace execution từng bước — feed vào `systematic-debugging`.

---

### 2.5 Graphify (Multimodal Knowledge Graph)

**Mục đích:** Knowledge graph hình ảnh + text toàn corpus (code, docs, design). Bổ trợ GitNexus: GitNexus chính xác call-graph; Graphify mờ/semantic và multimodal.

**Bắt buộc dùng khi:**
- Ngày đầu trên repo — đọc `graphify-out/GRAPH_REPORT.md`.
- Sau thay đổi architecture — `/graphify . --update`.
- Khi trace dependency xuyên module.

**Command nâng cao:**

| Command | Cho bạn gì |
|---|---|
| `/graphify .` | Full rebuild — dùng lần đầu hoặc khi arch thay đổi lớn |
| `/graphify . --update` | Incremental — dùng semantic cache, tiết kiệm 8.8x token |
| `/graphify query "câu hỏi"` | Query cấu trúc bằng ngôn ngữ tự nhiên trên toàn corpus |
| `/graphify path ServiceA ServiceB` | Đường đi ngắn nhất — tốt cho "A có đến được B không?" |

**Đọc `GRAPH_REPORT.md`:**
- **God nodes** — symbol có quá nhiều connection; ứng viên refactor.
- **Community cohesion** — module cohesion thấp là ứng viên để split.
- **Cross-community bridges** — cạnh chịu rủi ro coupling cao.
- **Suggested questions** — report tự nói bạn nên hỏi gì tiếp theo.

**Anti-patterns:**
- Chạy `/graphify .` (full rebuild) khi `--update` là đủ. Incremental path dùng semantic cache.
- Giả định Graphify up-to-date nếu `make index` chưa chạy từ merge gần nhất.
- Dùng Graphify cho câu hỏi call-graph chính xác — đó là việc của GitNexus.

**Phối hợp với:**
- Graphify trả lời "các vùng này liên quan về mặt concept như nào?" — GitNexus trả lời "function nào gọi function nào?" Dùng theo thứ tự đó.
- Sau khi BMAD Architect publish arch doc mới, `/graphify . --update` hút nó vào graph để query sau này tìm thấy.

---

### 2.6 claude-mem (Auto Session Memory)

**Mục đích:** Tự động capture những gì bạn làm mỗi session và re-inject context nén ở lần start tiếp theo. Zero config. Web viewer tại http://localhost:37777.

**Bắt buộc dùng khi:** Không bao giờ bằng tay. Nó tự chạy. Việc của bạn là **đừng chống lại nó.**

**Sử dụng nâng cao:**
- `claude-mem:mem-search` — search qua mọi session cũ bằng keyword.
- `claude-mem:timeline-report` — report kiểu "Journey Into [Project]".
- `claude-mem:knowledge-agent` — hỏi 1 câu; nó search memory và tổng hợp.
- `claude-mem:smart-explore` — search code cấu trúc tối ưu token dùng memory làm cache.

**Anti-patterns:**
- **Trùng lặp việc của claude-mem** bằng cách viết session summary vào MemPalace. claude-mem là session recall; MemPalace là decisions.
- Coi auto-injected context là sự thật *hiện tại*. Memory record đóng băng theo thời gian — verify với code live trước khi hành động.
- Nhồi knowledge vào `CLAUDE.md` thay vì để claude-mem xử lý.

**Phối hợp với:**
- claude-mem + MemPalace chia nhiệm vụ: session fact → claude-mem, knowledge có chủ đích → MemPalace. Tôn trọng sự phân chia.
- Trước khi bắt đầu việc, đọc section `$CMEM` xuất hiện lúc start session. Nó liệt kê ID session gần đây, expand bằng `get_observations([IDs])`.

---

### 2.7 MemPalace (Deliberate Knowledge Base)

**Mục đích:** Lưu nguyên văn, lossless cho architecture decision, team agreement, domain knowledge. Temporal knowledge graph: fact cũ có thể invalidate khi thế giới thay đổi. 19 MCP tools.

**Bắt buộc dùng khi:**
- Trước khi trả lời "tại sao hồi đó chọn X?" — search trước.
- Sau khi ra decision architecture không hiển nhiên — lưu lại.
- Cuối session có ý nghĩa — viết diary.
- Hàng tuần — mine conversation vào KG.

**Command nâng cao:**

| Tool | Dùng |
|---|---|
| `mempalace_search` | Full-text + semantic search trên mọi drawer |
| `mempalace_add_drawer` | Lưu decision nguyên văn |
| `mempalace_check_duplicate` | Trước khi add — tránh noise |
| `mempalace_kg_query` | Query temporal knowledge graph |
| `mempalace_kg_timeline` | Xem 1 fact tiến hóa theo thời gian |
| `mempalace_kg_invalidate` | Mark fact là đã bị thay thế |
| `mempalace_find_tunnels` | Phát lộ connection bất ngờ giữa các wing |
| `mempalace_diary_write` | Journal entry cuối session |
| `mempalace_get_taxonomy` | Liệt kê mọi wing/room/drawer để navigate |
| `mempalace mine ~/chats/ --mode convos` | Hàng tuần — extract decision từ chat log thô |

**Anti-patterns:**
- Dùng MemPalace cho "hôm qua tôi sửa file nào" — đó là claude-mem.
- Lưu session summary làm drawer — drawer là cho decision và lý do, không phải activity log.
- Không bao giờ chạy `mempalace mine` — KG sẽ stale và bỏ sót decision từ chat thô.
- Add drawer mà không `check_duplicate` — bạn sẽ có nhiều version competing cho cùng 1 fact.

**Phối hợp với:**
- MemPalace là memory layer cho BMAD Architect và OpenSpec design doc. Lưu design rationale ở đó, không chỉ trong commit message git.
- `mempalace_kg_invalidate` khi decision cũ bị thay thế bởi decision mới — giữ cho query downstream trung thực.

---

### 2.8 ECC (Everything Claude Code) Cherry-Pick

**Mục đích:** AgentShield security scanner + pre-tool-use hooks chặn secret và bảo vệ file config + skill coding standard theo ngôn ngữ. Cài đặt kiểu cherry-pick (không cần full ECC plugin).

**Bắt buộc dùng khi:**
- Mọi tool call (hook chạy thụ động — đừng bypass).
- Trước mọi PR (`make scan`).
- Trước mọi release (`make scan-deep` — model Opus, streaming).

**Command nâng cao:**

| Command | Dùng |
|---|---|
| `npx ecc-agentshield scan` | Fast scan, 102 rules |
| `npx ecc-agentshield scan --opus --stream` | Deep scan cho release candidate |
| Hooks trong `.claude/settings.json` | Thụ động — chặn secret, bảo vệ `.env`, canh MCP config |
| Skill: `golang-patterns` | Review Go idiomatic |
| Skill: `rust-patterns` | Review ownership + idiom |
| Skill: `python-patterns` | Review PEP 8 + Pythonic |
| Skill: `java-coding-standards` | Convention Spring Boot |
| Skill: `nestjs-patterns` | Review kiến trúc module NestJS |
| Skill: `nextjs-turbopack` | Review Next.js 16+ / Turbopack incremental |

**Anti-patterns:**
- Bypass hook bằng `--no-verify`. Nếu hook fire, điều tra — đừng suppress.
- Chỉ chạy fast scan trước release. `scan-deep` tồn tại có lý do.
- Sửa `.claude/settings.json` mà không hiểu hook nào làm gì. Đọc trước.

**Phối hợp với:**
- ECC skill (language patterns) được Superpowers `code-review` invoke để review đúng ngôn ngữ.
- AgentShield chạy trong pipeline `make review` (pre-PR) và `githooks/pre-push`.

---

## 3. Playbook phối hợp

Năm workflow tổng hợp. Mỗi cái dùng nhiều tool theo thứ tự cụ thể. Học thuộc — bạn sẽ dùng hàng ngày.

### Playbook A: "Tôi không hiểu code này"

```
1. cat graphify-out/GRAPH_REPORT.md             # Overview cấu trúc 5 phút
2. /graphify query "feature X hoạt động ra sao?" # Query corpus bằng ngôn ngữ tự nhiên
3. gitnexus_query({query: "<từ khóa feature>"}) # Flow call-graph
4. gitnexus_context({name: "<entrypoint>"})     # View 360° symbol nghi vấn
5. READ gitnexus://repo/vsaf/process/<name>     # Trace execution từng bước
6. mempalace_search("tại sao <feature>")        # Lý do lịch sử
```

**Tại sao thứ tự này:** Rộng → hẹp. Graphify cho hình dáng; GitNexus cho cạnh chính xác; MemPalace cho *lý do*. Đừng nhảy thẳng vào GitNexus context khi chưa có hình dáng — bạn sẽ lạc.

### Playbook B: "Tôi sắp refactor"

```
1. gitnexus_context({name: "target"})                     # Cái gì gọi nó, nó gọi cái gì
2. gitnexus_impact({target: "target", direction: "upstream"})  # Blast radius
3. /graphify path <target> <dependent nghi vấn>           # Xác nhận path nếu chưa chắc
4. mempalace_search("<target> lịch sử")                   # Có ai từng refactor chưa?
5. /opsx:propose refactor-<target>                        # Spec viết rõ + impact summary
6. /superpowers:brainstorm                                # 2-3 cách tiếp cận + trade-off
7. /superpowers:write-plan                                # Task list atomic
8. /superpowers:execute-plan                              # TDD cycles
9. gitnexus_detect_changes({scope: "staged"})             # Check scope trước commit
10. make review                                           # Review 3 lớp
```

**Gotcha:** Nếu bước 2 trả về d=1 caller bạn không ngờ tới, quay lại bước 5 và mở rộng proposal. Đừng "xử lý nhanh inline."

### Playbook C: "Tôi đang debug"

```
1. [auto] claude-mem inject context session gần đây        # Có thể đã có manh mối
2. claude-mem:mem-search "<error message>"                 # Đã gặp chưa?
3. gitnexus_query({query: "<triệu chứng>"})                # Tìm execution flow liên quan
4. gitnexus_context({name: "<function nghi vấn>"})         # Xem caller/callee
5. READ gitnexus://repo/vsaf/process/<processName>         # Trace flow
6. /superpowers:systematic-debugging                       # Hypothesis → experiment → conclusion
7. gitnexus_detect_changes({scope: "compare", base_ref: "main"})  # Branch này đã thay đổi gì?
8. [fix]  /superpowers:test-driven-development             # Viết test fail trước
9. mempalace_add_drawer                                    # Lưu root cause nếu không hiển nhiên
```

**Tại sao thứ tự này:** Memory trước (rẻ), graph sau (cấu trúc), methodology thứ 3 (kỷ luật), code cuối cùng.

### Playbook D: "Feature hoàn toàn mới"

```
Step 0:  make status                           # Tool khỏe chưa?
Step 1:  đọc GRAPH_REPORT.md + mempalace_search <domain>
Step 2:  *agent analyst                        # Scope
Step 3:  *agent pm + *agent architect          # PRD + arch
Step 4:  /opsx:propose <feature>               # Spec + design + tasks
         /opsx:ff                              # Fast-forward artifacts
Step 5:  gitnexus_impact trên mọi symbol bị đụng
         /graphify path <new> <existing>       # Điểm tích hợp
Step 6:  /superpowers:brainstorm               # Trade-off
         /superpowers:write-plan               # Task atomic
Step 7:  /superpowers:execute-plan             # TDD, 1 commit/task
         [ECC hook chạy thụ động]
Step 8:  /superpowers:code-review              # Layer 1
         make verify                           # Layer 2
         make index                            # Layer 3
         make scan                             # Security gate
Step 9:  git push                              # pre-push hook chạy lại verify + scan
Step 10: make archive && make mine             # Archive specs, mine decisions
```

Xem Section 4 cho ví dụ đầy đủ của playbook này.

### Playbook E: "Tôi vừa merge xong"

```
1. git pull
2. make index                 # GitNexus + Graphify re-index
3. make archive               # Chuyển change đã xong vào openspec/specs/
4. mempalace mine ~/chats/    # (Hàng tuần, không phải mỗi lần merge)
5. make status                # Xác nhận mọi thứ khỏe
```

**Tại sao:** Knowledge graph local của bạn stale ngay khi người khác merge. 30 giây này tiết kiệm 1 giờ debug dựa trên kết quả `gitnexus_impact` đã lỗi thời.

---

## 4. Demo SDLC toàn trình

### Feature: Thêm JWT refresh token rotation cho auth service

**Bối cảnh:** Security team flag access token dài hạn là rủi ro. Cần implement access token ngắn (15 phút) với refresh token rotate mỗi lần dùng (phát hiện reuse sẽ revoke cả family).

Walkthrough này show mọi tool VSAF trong 1 flow liên tục. Command thật, snippet output thực tế, và các gotcha dev mới sẽ đụng.

---

#### Step 0 — Pre-flight

```bash
make status
```

Output mong đợi: cả 8 tool báo khỏe. Nếu GitNexus báo "not indexed", chạy `gitnexus analyze` trước. Nếu MemPalace báo "not initialized", bạn đã bỏ setup — chạy `make setup`.

**Gotcha:** `make status` có thể pass ngay cả khi `graphify-out/` stale. Check mod time — nếu cũ hơn merge gần nhất, chạy `make index`.

---

#### Step 1 — Hiểu codebase

```bash
cat graphify-out/GRAPH_REPORT.md | less
```

Tìm: community auth/session, god node trong module auth, cross-community bridge nào liên quan đến auth.

Rồi trong Claude Code:

```
/graphify query "auth flow hiện tại issue token ra sao?"
```

Tiếp theo:

```
gitnexus_query({query: "token issuance"})
gitnexus_context({name: "issueAccessToken"})
READ gitnexus://repo/vsaf/process/login-flow
```

Cuối cùng, check tiền lệ:

```
mempalace_search("refresh token rotation")
mempalace_search("auth token decisions")
```

**Gotcha:** Nếu MemPalace trả về drawer cũ bảo "đã chọn sliding session thay vì rotation năm 2024", đọc nó — bạn có thể đang lật ngược decision cũ. Nếu vậy, lên kế hoạch `mempalace_kg_invalidate` khi design mới ra.

---

#### Step 2 — Scope

```
*agent analyst
```

Analyst hỏi các câu làm rõ. Trả lời:
- Tại sao bây giờ? → phát hiện security audit.
- Ràng buộc? → không được breaking change với mobile client đang chạy.
- Tiêu chí thành công? → phát hiện reuse revoke family trong 1 giây; test chứng minh rotation.
- Ngoài scope? → thay đổi thuật toán encrypt token.

```
*workflow-init
```

Chọn **Standard Flow** (không phải Quick Flow) — việc này đụng nhiều module và có implication security.

---

#### Step 3 — Plan

```
*agent pm
```

PM cho ra `docs/prd.md`:
- **FR-1** Access token hết hạn sau 15 phút.
- **FR-2** Refresh token rotate mỗi lần dùng.
- **FR-3** Reuse refresh token đã tiêu thụ thì revoke cả token family.
- **FR-4** Mobile client dùng API cũ vẫn hoạt động 90 ngày.
- **NFR-1** Rotation latency < 50ms p99.
- **NFR-2** Revocation lan ra mọi instance trong < 1 giây.

```
*agent architect
```

Architect cho ra `docs/architecture/auth-refresh-rotation.md`:
- Mô hình token family (parent_id link chain).
- Revocation list backed bởi Redis với TTL 90 ngày.
- Thay đổi middleware ở `AuthGuard`.
- Chiến lược migrate: dual-write claim cũ + mới trong 30 ngày.

```bash
git add docs/ && git commit -m "feat: PRD + arch for refresh token rotation"
```

**Gotcha:** Commit output BMAD ngay lập tức. Bạn sẽ muốn chúng trong context OpenSpec proposal ở step sau, và `execute-plan` cần chúng trên disk.

---

#### Step 4 — Specs

```
/opsx:propose refresh-token-rotation
```

Tạo `openspec/changes/refresh-token-rotation/` với `proposal.md`, `design.md`, `tasks.md`. Review task list — mỗi task phải atomic (2–5 phút làm) và có verification step.

```
/opsx:ff
```

Fast-forward artifact liên quan để mọi doc đều trỏ cùng version.

```bash
git add openspec/ && git commit -m "spec: refresh token rotation"
```

**Gotcha:** Nếu 1 task thiếu verification step, đừng approve proposal — gửi lại `/opsx:propose` để sửa. Superpowers `execute-plan` sẽ từ chối chạy task không có verification.

---

#### Step 5 — Impact analysis

Trong Claude Code:

```
gitnexus_impact({target: "AuthGuard", direction: "upstream"})
```

Output ví dụ:
- d=1: `AppModule`, `AdminModule`, `BillingModule`, `MobileApiController`
- d=2: 23 route handler
- d=3: transitively 80% codebase
- **Risk: HIGH**

Báo cho user. **Đừng tiếp tục âm thầm.**

```
gitnexus_impact({target: "issueAccessToken", direction: "upstream"})
/graphify path AuthGuard MobileApiController
```

Check tiền lệ:

```
mempalace_search("AuthGuard refactor")
```

**Decision gate:** HIGH impact → split PR. Quay lại `/opsx:propose` và chia thành:
1. `refresh-token-model` (chỉ data layer)
2. `refresh-token-issuance` (service layer)
3. `refresh-token-middleware` (thay đổi AuthGuard sau feature flag)
4. `refresh-token-rollout` (bật flag, migrate client)

Chạy lại `/opsx:ff` sau khi split.

**Gotcha:** "Impact > 3 module → split PR" nằm trong `CLAUDE.md`. Không tùy chọn.

---

#### Step 6 — Brainstorm + plan (cho sub-PR #1: `refresh-token-model`)

```
/superpowers:brainstorm
```

Skill brainstorm hỏi câu làm rõ và đề xuất 2-3 cách tiếp cận:
- **A.** 1 bảng `refresh_tokens(parent_id, family_id, consumed_at)`.
- **B.** 2 bảng: `token_families` + `refresh_tokens`.
- **C.** Redis-only với snapshot định kỳ xuống Postgres.

Bàn trade-off. Chọn **B** (chia rõ ràng, dễ index).

```
/superpowers:write-plan
```

Plan ghi vào `docs/superpowers/plans/refresh-token-model.md`. Mỗi task có verification step ("test X pass", "migration apply sạch trên DB mới", "`gitnexus_detect_changes` chỉ show những file này").

Review plan. Approve explicit.

**Gotcha:** `write-plan` sẽ cho ra rác nếu bạn bỏ `brainstorm`. Skill priority (process skill trước implementation skill) tồn tại có lý do.

---

#### Step 7 — Execute

```
/superpowers:execute-plan
```

Skill chạy RED → GREEN → REFACTOR cho từng task:
1. **RED:** viết test fail. Xác nhận nó fail đúng lý do.
2. **GREEN:** code tối thiểu để pass.
3. **REFACTOR:** dọn dẹp không làm hỏng test.
4. **COMMIT:** 1 commit/task, message theo `<type>: <description>`.

Trong lúc execute:
- ECC hook chặn secret hoặc write config vô tình.
- PostToolUse hook re-index GitNexus sau mỗi commit.
- claude-mem tự capture việc bạn làm.

**Gotcha:** Nếu 1 task fail 3 lần liên tiếp, DỪNG. Đừng cố đấm. Trigger architectural review — có gì đó trong plan sai. Update plan, đừng brute-force task.

---

#### Step 8 — Review 3 lớp

```
/superpowers:code-review
```

Layer 1 (methodology): check code vs plan, ECC coding-standard skill (`nestjs-patterns` cho phần NestJS), và consistency architecture.

```bash
make verify
```

Layer 2 (spec compliance): `openspec validate --all`. Nếu fail, quay lại Step 7.

```bash
make index
```

Layer 3 (graph sync): re-index để GitNexus + Graphify phản ánh code mới.

```bash
make scan
```

Security gate trước PR.

**Gotcha:** Chạy *theo đúng thứ tự*. Layer 1 bắt lỗi methodology thì rẻ; Layer 2 bắt spec drift sau khi đã push thì đắt.

---

#### Step 9 — Push

```bash
git push origin feature/refresh-token-model
```

`githooks/pre-push` tự chạy `make verify` + `make scan`. Nếu 1 trong 2 fail, push bị chặn. Fix locally — **đừng** bypass bằng `--no-verify`.

Template mô tả PR:
```
## Summary
Thêm bảng token family + refresh_tokens cho refresh token rotation.

## OpenSpec proposal
openspec/changes/refresh-token-model/proposal.md

## Impact
- d=1: migrations runner, AuthModule tests
- d=2: none (sau feature flag)
- HIGH risk giảm bằng cách split thành 4 PR; đây là PR 1/4.

## Tests
- 14 test mới, tất cả pass
- Migration apply trên DB mới trong < 200ms
- `openspec validate --all`: passing
```

---

#### Step 10 — Archive + ship

Sau khi PR merge:

```bash
git pull
make archive      # openspec archive + re-index
make mine         # mine decisions từ ~/chats/ vào MemPalace (hàng tuần)
```

Cho release:

```bash
make scan-deep    # Opus + streaming
git tag v1.4.0 && git push --tags
```

Lưu decision cuối vào MemPalace cho bạn trong tương lai:

```
mempalace_add_drawer
  wing: architecture
  room: auth
  drawer: refresh-token-rotation-v1
  content: "Chọn mô hình token family B (2 bảng) thay vì Redis-only (C)
            vì Postgres là source of truth và Redis availability không
            được đảm bảo trong lúc regional failover. Family_id indexed
            để revocation O(1). TTL 90 ngày match compliance retention.
            Split thành 4 PR vì AuthGuard impact HIGH (23 d=2 route
            handler). Xem openspec/specs/refresh-token-* để chi tiết."
```

Nếu bạn đang thay thế decision cũ:

```
mempalace_kg_invalidate <old-drawer-id>
```

**Xong.** Dev tiếp theo hỏi "tại sao rotate refresh token?" sẽ có câu trả lời đầy đủ chỉ qua 1 search.

---

## 5. Mẹo nâng cao

### Làm song song với worktree

Khi cần làm 2 feature không muốn context switch:

```
/superpowers:using-git-worktrees
```

Tạo worktree isolated. Main worktree vẫn sạch. Tốt cho: chạy `execute-plan` trong 1 worktree trong khi explore bug khác trong worktree khác.

### Agent song song cho research độc lập

Khi có 2+ câu hỏi độc lập ("audit 4 file này", "research 3 thư viện này"):

```
/superpowers:dispatching-parallel-agents
```

Skill dispatch sub-agent concurrent. Đừng dùng cho task phụ thuộc — chỉ khi kết quả thật sự độc lập.

### Subagent-driven execution cho plan dài

Với plan 20+ task, thay vì `execute-plan` tuần tự:

```
/superpowers:subagent-driven-development
```

Dispatch task cho sub-agent với two-phase review pipeline. Mỗi sub-agent nhận prompt self-contained; bạn review summary của chúng trước khi merge.

### Vệ sinh hàng tuần

| Tần suất | Command | Tại sao |
|---|---|---|
| Mỗi merge | `make index` | Giữ GitNexus + Graphify fresh |
| Mỗi merge | `make archive` | Giữ `openspec/changes/` gọn |
| Hàng tuần | `make mine` | Extract decision từ chat thô vào MemPalace |
| Hàng tuần | `mempalace_find_tunnels` | Phát lộ connection cross-wing bất ngờ |
| Hàng tháng | `make scan-deep` | Audit security sâu |
| Release | `make scan-deep` | Gate bắt buộc trước release |

### Đọc `GRAPH_REPORT.md` hiệu quả

Đừng đọc từ trên xuống. Nhảy tới các section này trước:
1. **Suggested questions** — nói thẳng bạn nên hỏi gì tiếp.
2. **God nodes** — ứng viên refactor, blast radius cao.
3. **Cross-community bridges** — rủi ro coupling.
4. **Communities** — module map.

---

## 6. Troubleshooting

| Triệu chứng | Nguyên nhân có thể | Sửa |
|---|---|---|
| `gitnexus_impact` báo "index stale" | Người khác đã merge | `gitnexus analyze` (hoặc `make index`) |
| `gitnexus_impact` thiếu caller bạn biết có | Chưa có embeddings | `gitnexus analyze --embeddings` |
| `/graphify . --update` than cache | Backup bị xóa trước khi diff | Chạy full `/graphify .` 1 lần, rồi resume incremental |
| `make verify` fail sau `execute-plan` | Spec drift khỏi code | Đừng sửa spec cho match — fix code cho match spec |
| PreToolUse hook chặn mọi action | JSON hỏng trong `.claude/settings.json` | Validate bằng `jq '.' .claude/settings.json` |
| MemPalace trả về fact stale | Fact bị thay thế nhưng chưa invalidate | `mempalace_kg_invalidate <drawer-id>` |
| claude-mem không inject context | Session viewer không chạy | Check http://localhost:37777; restart Claude Code |
| Warning ECC skill "not found" khi `make setup` | Path skill upstream đã thay đổi | Đã fix — pull latest, chạy lại `make setup` |
| `make archive` fail với "no approved changes" | Bạn archive trước khi merge | Archive chỉ *sau* khi PR merge |
| `execute-plan` từ chối start | Plan có task thiếu verification | Chạy lại `write-plan` với verification gate |
| `gitnexus_rename` dry-run show hit lạ | `text_search` fallback match string literal | Review và approve hoặc skip từng cái |
| Layer 2 pass nhưng code sai | Spec sai | Update spec qua `/opsx:propose` revision, không phải code |
| Hook fire trên file hợp lệ | Path glob quá rộng | Đọc `.claude/settings.json`, thắt glob lại, đừng add `--no-verify` |

---

## Nguyên tắc cốt lõi (học thuộc)

1. **Spec trước code.** Luôn luôn. Quick Flow là ngoại lệ duy nhất và nó vẫn cần plan.
2. **Context là vua.** Đọc Graphify + GitNexus + MemPalace *trước* khi đụng code.
3. **Git là source of truth.** Commit output BMAD, artifact OpenSpec, và plan ngay khi có.
4. **Review 3 lớp trước mọi PR.** Methodology → spec → graph sync.
5. **Re-index sau mọi merge.** `make index`.
6. **Mine decision hàng tuần.** `make mine`.
7. **Không bao giờ bypass hook.** Nếu hook fire, hook đúng cho đến khi chứng minh ngược lại.
8. **Split khi impact HIGH.** PR > 400 dòng hoặc > 3 module phải split.
9. **Memory có sự phân chia.** claude-mem = session. MemPalace = decision. Đừng trộn stream.
10. **Nếu task fail 3 lần, DỪNG.** Vấn đề kiến trúc, không phải vấn đề execution.

---

**Các bước tiếp theo cho dev mới:**
1. Chạy `make setup` và `make status`.
2. Đọc [1-setup-guide.md](1-setup-guide.md) từ đầu đến cuối.
3. Đọc lại Section 4 của file này (demo JWT) — hiểu mọi command trước khi đụng code thật.
4. Chọn 1 task nhỏ xíu (sửa typo, update doc). Chạy qua Quick Flow.
5. Rồi chọn feature nhỏ. Chạy qua Standard Flow từ Section 4.
6. Hỏi câu hỏi. Rẻ hơn làm lại PR.
