const API_BASE = "{{ .Site.Params.commentsApi }}";
const el = (id) => document.getElementById(id);

window.onTurnstileSuccess = function (token) {
  el("turnstileToken").value = token;
};

function escapeHTML(s) {
  if (!s) return '';
  return s.replaceAll('&', '&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('\"','&quot;');
}

function timeAgo(iso) {
  const d = new Date(iso);
  const diff = Math.floor((Date.now() - d.getTime()) / 1000);
  if (diff < 60) return diff + 's';
  if (diff < 3600) return Math.floor(diff/60) + 'm';
  if (diff < 86400) return Math.floor(diff/3600) + 'h';
  return Math.floor(diff/86400) + 'd';
}

function createCommentNode(comment) {
  const container = document.createElement('article');
  container.className = 'p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-100 dark:border-gray-800';
  container.dataset.id = comment.id;
  container.innerHTML = `
    <div class="flex items-start gap-3">
      <div class="flex-1">
        <div class="flex items-baseline justify-between">
          <div class="text-sm font-medium">${escapeHTML(comment.author)} <span class="text-xs text-gray-400 dark:text-gray-500">· ${timeAgo(comment.created_at)}</span></div>
          <div>
            <button data-reply class="text-xs px-2 py-1 rounded text-gray-500 hover:text-gray-700 dark:hover:text-gray-300">reply</button>
          </div>
        </div>
        <p class="mt-2 text-sm whitespace-pre-wrap">${escapeHTML(comment.content)}</p>
        <div class="mt-3 space-y-2" data-replies></div>
      </div>
    </div>`;
  return container;
}

function insertComment(comment, prepend = true) {
  const node = createCommentNode(comment);
  if (comment.parent_id) {
    const parent = el('comments').querySelector(`[data-id="${comment.parent_id}"]`);
    if (parent) {
      const replies = parent.querySelector('[data-replies]');
      if (prepend) replies.prepend(node); else replies.append(node);
      return;
    }
  }
  if (prepend) el('comments').prepend(node); else el('comments').append(node);
}

function renderCommentThread(comment) {
  insertComment(comment, false);
  if (comment.replies && comment.replies.length) {
    comment.replies.forEach(r => renderCommentThread(r));
  }
}

async function fetchComments() {
  const siteId = el('siteId').value;
  const postSlug = el('postSlug').value;
  try {
    const res = await fetch(`${API_BASE}/comments/${encodeURIComponent(siteId)}/${encodeURIComponent(postSlug)}`);
    if (!res.ok) throw new Error(await res.text() || res.statusText);
    const comments = await res.json();
    el('comments').innerHTML = '';
    comments.forEach(c => renderCommentThread(c));
  } catch (err) {
    console.error('Failed to load comments:', err);
  }
}

function openReplyForm(parentNode, parentId) {
  if (parentNode.querySelector('[data-reply-form]')) return;
  const form = document.createElement('form');
  form.dataset.replyForm = '1';
  form.className = 'mt-3 p-2 bg-gray-50 dark:bg-gray-900 rounded';
  form.innerHTML = `
    <textarea name="content" rows="3" class="w-full px-2 py-1 rounded border border-gray-200 dark:border-gray-700 bg-transparent text-sm" placeholder="Reply..."></textarea>
    <div class="mt-2 flex gap-2">
      <input name="author" placeholder="Name" class="px-2 py-1 rounded border border-gray-200 dark:border-gray-700 text-sm" required />
      <input name="email" placeholder="Email" class="px-2 py-1 rounded border border-gray-200 dark:border-gray-700 text-sm" required />
      <button class="px-3 py-1 rounded bg-gray-100 dark:bg-gray-700 text-sm">Reply</button>
      <button type="button" class="px-3 py-1 rounded text-sm text-gray-500" data-cancel>Cancel</button>
    </div>`;
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const payload = {
      site_id: el('siteId').value,
      post_slug: el('postSlug').value,
      author: form.author.value.trim() || 'Anonymous',
      email: form.email.value.trim(),
      content: form.content.value.trim(),
      parent_id: parentId,
      turnstile_token: el('turnstileToken').value || ''
    };
    await postComment(payload, {onSuccess: (saved) => {
      insertComment(saved, true);
      form.remove();
      if (window.turnstile && window.turnstile.reset) window.turnstile.reset();
    }});
  });
  form.querySelector('[data-cancel]').addEventListener('click', () => form.remove());
  parentNode.querySelector('[data-replies]').prepend(form);
  form.querySelector('textarea').focus();
}

async function postComment(payload, opts = {}) {
  const status = el('status');
  const submitBtn = el('submitBtn');
  try {
    submitBtn.disabled = true;
    status.textContent = 'Posting...';
    const res = await fetch(`${API_BASE}/comments`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (!res.ok) throw new Error(await res.text() || res.statusText);
    const saved = await res.json();
    status.textContent = '';
    if (opts.onSuccess) opts.onSuccess(saved);
    if (!payload.parent_id) el('content').value = '';
    if (window.turnstile && window.turnstile.reset) window.turnstile.reset();
    return saved;
  } catch (err) {
    console.error('Post comment failed', err);
    status.textContent = 'Failed to post';
    return null;
  } finally {
    submitBtn.disabled = false;
    setTimeout(()=>{ if (status.textContent === 'Failed to post') status.textContent = ''; }, 3000);
  }
}

document.addEventListener('click', (e) => {
  const btn = e.target.closest('[data-reply]');
  if (btn) {
    const article = btn.closest('article');
    const id = article?.dataset?.id;
    if (id) openReplyForm(article, Number(id));
  }
});

el('commentForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const payload = {
    site_id: el('siteId').value,
    post_slug: el('postSlug').value,
    author: el('author').value.trim() || 'Anonymous',
    email: el('email').value.trim(),
    content: el('content').value.trim(),
    parent_id: null,
    turnstile_token: el('turnstileToken').value || ''
  };
  await postComment(payload, { onSuccess: (saved) => insertComment(saved, true) });
});

// Fetch existing comments on page load
document.addEventListener('DOMContentLoaded', fetchComments);
