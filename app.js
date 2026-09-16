const state = {
  tab: "All",
  search: "",
  favorites: new Set(),
  custom: [],
  states: { Idle: "", Walk: "", Jump: "" },
  size: 1
};

const builtIn = [
  "15 MINUTES", "2 arm stroke", "360", "7 Rings Dance",
  "8-Bit Shuffle", "9mm Go Bang!", "A Bar Song",
  "Chief Keef", "Moonwalk", "Wave"
];

const panel = document.querySelector("#panel");
const search = document.querySelector("#search");
const tabs = document.querySelector("#tabs");
const addDialog = document.querySelector("#addDialog");
const addForm = document.querySelector("#addForm");

function allAnimations() {
  return [
    ...builtIn.map(name => ({ name, type: "Built-in" })),
    ...state.custom.map(item => ({ name: item.name, type: "Custom", data: item }))
  ];
}

function filteredAnimations() {
  const q = state.search.trim().toLowerCase();
  let list = allAnimations();

  if (state.tab === "Favs") {
    list = list.filter(item => state.favorites.has(item.name));
  } else if (state.tab === "Custom") {
    list = list.filter(item => item.type === "Custom");
  } else if (state.tab === "Binds") {
    list = [];
  } else if (state.tab !== "All") {
    list = [];
  }

  if (q) list = list.filter(item => item.name.toLowerCase().includes(q));
  return list;
}

function render() {
  document.querySelectorAll(".tab").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.tab === state.tab);
  });

  search.style.display = ["All", "Favs", "Custom"].includes(state.tab) ? "" : "none";
  document.querySelector("#addButton").style.display = state.tab === "Custom" ? "" : "none";

  if (state.tab === "States") return renderStates();
  if (state.tab === "Size") return renderSize();
  if (state.tab === "Binds") return renderBinds();

  const list = filteredAnimations();
  if (!list.length) {
    panel.innerHTML = `<div class="empty">No animations found.</div>`;
    return;
  }

  panel.innerHTML = `<div class="list">${list.map(item => `
    <div class="animation-row">
      <span class="row-mark">✦</span>
      <span class="row-name">${escapeHtml(item.name)}</span>
      <span class="row-type">${escapeHtml(item.type)}</span>
      <button class="favorite ${state.favorites.has(item.name) ? "active" : ""}"
              data-fav="${escapeAttr(item.name)}" title="Favorite">☆</button>
    </div>
  `).join("")}</div>`;

  panel.querySelectorAll("[data-fav]").forEach(btn => {
    btn.addEventListener("click", () => {
      const name = btn.dataset.fav;
      if (state.favorites.has(name)) state.favorites.delete(name);
      else state.favorites.add(name);
      render();
    });
  });
}

function renderStates() {
  const names = allAnimations().map(x => x.name);
  panel.innerHTML = `
    <div class="state-grid">
      ${["Idle", "Walk", "Jump"].map(key => `
        <div class="state-card">
          <div class="state-name">${key.toUpperCase()}</div>
          <select data-state="${key}">
            <option value="">Select animation</option>
            ${names.map(name =>
              `<option value="${escapeAttr(name)}" ${state.states[key] === name ? "selected" : ""}>${escapeHtml(name)}</option>`
            ).join("")}
          </select>
        </div>
      `).join("")}
    </div>
  `;
  panel.querySelectorAll("[data-state]").forEach(select => {
    select.addEventListener("change", () => {
      state.states[select.dataset.state] = select.value;
    });
  });
}

function renderSize() {
  panel.innerHTML = `
    <div class="size-card">
      <div class="size-value">${Math.round(state.size * 100)}%</div>
      <input id="sizeRange" type="range" min="50" max="200" value="${Math.round(state.size * 100)}">
    </div>
  `;
  document.querySelector("#sizeRange").addEventListener("input", e => {
    state.size = Number(e.target.value) / 100;
    renderSize();
  });
}

function renderBinds() {
  panel.innerHTML = `<div class="empty">Binds UI is ready for the keybind system.</div>`;
}

tabs.addEventListener("click", e => {
  const btn = e.target.closest(".tab");
  if (!btn) return;
  state.tab = btn.dataset.tab;
  render();
});

search.addEventListener("input", () => {
  state.search = search.value;
  render();
});

document.querySelector("#addButton").addEventListener("click", () => {
  document.querySelector("#animationName").value = "";
  document.querySelector("#keyframeData").value = "";
  addDialog.showModal();
});

addForm.addEventListener("submit", e => {
  if (e.submitter?.value !== "save") return;
  e.preventDefault();

  const name = document.querySelector("#animationName").value.trim();
  const keyframes = document.querySelector("#keyframeData").value.trim();

  if (!name || !keyframes) return;

  if (allAnimations().some(x => x.name.toLowerCase() === name.toLowerCase())) {
    alert("That animation name already exists.");
    return;
  }

  state.custom.push({
    name,
    keyframes,
    format: "DayBreakAnimation",
    version: 1
  });

  state.tab = "Custom";
  addDialog.close();
  render();
});

document.querySelectorAll(".module").forEach(btn => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".module").forEach(x => x.classList.remove("active"));
    btn.classList.add("active");
    document.querySelector("#moduleTitle").textContent = btn.dataset.module;
  });
});

document.querySelector("#themeSpark").addEventListener("click", () => {
  document.body.classList.toggle("bright");
});

function escapeHtml(value) {
  return value.replace(/[&<>"']/g, c => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;"
  }[c]));
}
function escapeAttr(value) { return escapeHtml(value); }

render();
