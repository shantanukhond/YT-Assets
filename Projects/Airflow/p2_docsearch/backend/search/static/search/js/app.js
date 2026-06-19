const MIN_QUERY_LENGTH = 2;
const DEBOUNCE_MS = 400;

const page = document.getElementById("page");
const main = document.getElementById("main");
const searchInput = document.getElementById("search-input");
const searchForm = document.getElementById("search-form");
const searchStatus = document.getElementById("search-status");
const resultsHeader = document.getElementById("results-header");
const resultsList = document.getElementById("results-list");

let debounceTimer = null;
let activeController = null;

function setStatus(message, type = "") {
  searchStatus.textContent = message;
  searchStatus.className = `search-status${type ? ` is-${type}` : ""}`;
}

function setPageMode(isActive) {
  page.classList.toggle("is-active", isActive);
  main.hidden = !isActive;
}

function formatBreadcrumb(url) {
  try {
    const parsed = new URL(url);
    const path = parsed.pathname.replace(/\/$/, "").split("/").filter(Boolean).join(" › ");
    return `${parsed.hostname}${path ? ` › ${path}` : ""}`;
  } catch {
    return url;
  }
}

function renderResults(query, results) {
  resultsList.innerHTML = "";
  const isActive = query.length >= MIN_QUERY_LENGTH;
  setPageMode(isActive);

  if (!isActive) {
    resultsHeader.hidden = true;
    return;
  }

  resultsHeader.hidden = false;
  resultsHeader.textContent = `About ${results.length} result${results.length === 1 ? "" : "s"}`;

  if (!results.length) {
    resultsList.innerHTML =
      '<li class="empty-state">Your search did not match any documents.</li>';
    return;
  }

  results.forEach((doc) => {
    const item = document.createElement("li");
    item.innerHTML = `
      <a
        class="result-item"
        href="/documents/${doc.id}/"
        target="_blank"
        rel="noopener noreferrer"
      >
        <span class="result-url">${escapeHtml(formatBreadcrumb(doc.source_url))}</span>
        <span class="result-title">${escapeHtml(doc.title)}</span>
        <span class="result-snippet">Relevance score ${doc.distance === null || doc.distance === undefined ? "n/a" : Number(doc.distance).toFixed(4)}</span>
      </a>
    `;
    resultsList.appendChild(item);
  });
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

async function fetchSuggestions(query) {
  if (activeController) {
    activeController.abort();
  }

  activeController = new AbortController();
  setStatus("Searching...", "loading");

  try {
    const response = await fetch(
      `/api/suggest/?q=${encodeURIComponent(query)}`,
      { signal: activeController.signal }
    );

    if (!response.ok) {
      throw new Error(`Search failed (${response.status})`);
    }

    const data = await response.json();
    renderResults(data.query, data.results);
    setStatus("");
    updateUrl(query);
  } catch (error) {
    if (error.name === "AbortError") {
      return;
    }
    renderResults(query, []);
    setStatus(error.message, "error");
  } finally {
    activeController = null;
  }
}

function scheduleSearch(query) {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    if (query.length < MIN_QUERY_LENGTH) {
      renderResults(query, []);
      setStatus("");
      updateUrl("");
      return;
    }
    fetchSuggestions(query);
  }, DEBOUNCE_MS);
}

function updateUrl(query) {
  const url = new URL(window.location.href);
  if (query) {
    url.searchParams.set("q", query);
  } else {
    url.searchParams.delete("q");
  }
  window.history.replaceState({}, "", url);
}

searchInput.addEventListener("input", () => {
  scheduleSearch(searchInput.value.trim());
});

searchForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const query = searchInput.value.trim();
  clearTimeout(debounceTimer);
  if (query.length < MIN_QUERY_LENGTH) {
    renderResults(query, []);
    setStatus("");
    return;
  }
  fetchSuggestions(query);
});

const initialQuery = searchInput.value.trim();
if (initialQuery.length >= MIN_QUERY_LENGTH) {
  fetchSuggestions(initialQuery);
} else {
  renderResults(initialQuery, []);
}
