# English learning profile via Git

Use a user-owned private Git repository as the existing state directory. Track only knowledge.json; ignore sessions, turns, lock and temporary files. Keep on/off local and support explicit agent-operated sync and sync --push. Git performs ordinary merges; conflicts stop synchronization for user resolution. No semantic merge or automatic network access during normal learning.

The hook must accept both sync invocations without toggling language mode. The agent checks repository, remote, branch, identity, staged content and schema before committing or pushing. Only knowledge.json is committed. A concurrent writer requires pausing other learning chats during synchronization. No remote repository is created without its destination being supplied.

## Plan thực thi

[Plan](../plans/2026-10-14-english-git-profile.md)

[Summary](../summaries/2026-10-14-english-git-profile-summary.md)
