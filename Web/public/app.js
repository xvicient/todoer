import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getFirestore, collection, query, where, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
import { getAuth, GoogleAuthProvider, signInWithPopup, onAuthStateChanged, signOut, setPersistence, browserLocalPersistence } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
import { firebaseConfig } from './config.js';

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
const provider = new GoogleAuthProvider();

const displayEl = document.getElementById('data-display');
const btnLogin = document.getElementById('btn-login');
const btnLogout = document.getElementById('btn-logout');
const userInfoSection = document.getElementById('user-info');
const appContent = document.getElementById('app-content');
const loginPrompt = document.getElementById('login-prompt');
const exportBtn = document.getElementById('export-btn');
const btnNewList = document.getElementById('btn-new-list');
const searchInput = document.getElementById('search-lists');

// Filter Buttons
const btnAll = document.getElementById('filter-all');
const btnTodo = document.getElementById('filter-todo');
const btnDone = document.getElementById('filter-done');

const ICON_EDIT = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4L18.5 2.5z"></path></svg>`;
const ICON_DELETE = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>`;

let currentUser = null;
let allLists = [];
let currentFilter = 'all'; // all, todo, done

function linkify(text) {
    const urlRegex = /(https?:\/\/[^\s]+)/g;
    return text.replace(urlRegex, (url) => `<a href="${url}" target="_blank" rel="noopener noreferrer">${url}</a>`);
}

setPersistence(auth, browserLocalPersistence);

onAuthStateChanged(auth, (user) => {
    if (user) {
        currentUser = user;
        loginPrompt.style.display = 'none';
        appContent.style.display = 'block';
        userInfoSection.style.display = 'flex';
        fetchLists(user.uid);
    } else {
        currentUser = null;
        loginPrompt.style.display = 'block';
        appContent.style.display = 'none';
        userInfoSection.style.display = 'none';
    }
});

if (btnLogin) {
    btnLogin.onclick = async () => {
        try {
            btnLogin.innerText = "Connecting...";
            await signInWithPopup(auth, provider);
        } catch (error) {
            btnLogin.innerText = "Sign in with Google";
        }
    };
}

if (btnLogout) btnLogout.onclick = () => signOut(auth);

// Global Filter Application
function applyFilters() {
    const term = searchInput.value.toLowerCase();
    let filtered = allLists.filter(l => (l.name || "").toLowerCase().includes(term));
    
    if (currentFilter === 'todo') {
        filtered = filtered.filter(l => !l.isDone);
    } else if (currentFilter === 'done') {
        filtered = filtered.filter(l => l.isDone);
    }
    
    renderLists(filtered);
}

if (searchInput) {
    searchInput.oninput = () => applyFilters();
}

// Button listeners
[btnAll, btnTodo, btnDone].forEach(btn => {
    btn.onclick = () => {
        [btnAll, btnTodo, btnDone].forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentFilter = btn.id.split('-')[1];
        applyFilters();
    };
});

btnNewList.onclick = async () => {
    const listName = prompt("New List Name:");
    if (!listName?.trim()) return;
    await addDoc(collection(db, "lists"), { name: listName.trim(), uid: [currentUser.uid], timestamp: serverTimestamp() });
    fetchLists(currentUser.uid);
};

async function fetchLists(uid) {
    const q = query(collection(db, "lists"), where("uid", "array-contains", uid));
    const snap = await getDocs(q);
    const tempLists = [];
    snap.forEach(d => tempLists.push({ id: d.id, ...d.data() }));

    allLists = await Promise.all(tempLists.map(async (list) => {
        const itemSnap = await getDocs(collection(db, "lists", list.id, "items"));
        const items = [];
        itemSnap.forEach(idoc => items.push(idoc.data()));
        const isDone = items.length > 0 && items.every(i => i.done === true);
        return { ...list, isDone };
    }));

    allLists.sort((a, b) => {
        if (a.isDone !== b.isDone) return a.isDone ? 1 : -1;
        return (a.name || "").localeCompare(b.name || "", undefined, {sensitivity: 'base'});
    });

    applyFilters();
}

function renderLists(listsToRender) {
    displayEl.innerHTML = "";
    listsToRender.forEach(list => {
        const card = document.createElement('div');
        card.className = 'list-card';
        card.innerHTML = `
            <div class="list-header" id="header-${list.id}">
                <span class="list-title ${list.isDone ? 'done-list' : ''}" id="title-span-${list.id}">${linkify(list.name || 'List')}</span>
                <div class="item-actions">
                    <button class="btn-icon" id="edit-l-${list.id}">${ICON_EDIT}</button>
                    <button class="btn-icon" id="delete-l-${list.id}">${ICON_DELETE}</button>
                </div>
            </div>
            <div id="sub-${list.id}" style="display:none;">
                <div id="items-list-${list.id}"></div>
                <div class="add-form">
                    <input type="text" id="input-${list.id}" placeholder="New task...">
                    <button class="btn-small-add" id="btn-add-${list.id}">Add</button>
                </div>
            </div>`;
        displayEl.appendChild(card);
        
        document.getElementById(`header-${list.id}`).onclick = (e) => { 
            if(e.target.tagName !== 'A' && !e.target.closest('.btn-icon')) {
                toggleItems(list.id);
            }
        };
        
        document.getElementById(`edit-l-${list.id}`).onclick = (e) => { e.stopPropagation(); editList(list.id, list.name); };
        document.getElementById(`delete-l-${list.id}`).onclick = (e) => { e.stopPropagation(); deleteList(list.id); };
        document.getElementById(`btn-add-${list.id}`).onclick = () => addItem(list.id);
    });
}

async function toggleItems(id) {
    const box = document.getElementById(`sub-${id}`);
    const isVisible = box.style.display === "block";
    box.style.display = isVisible ? "none" : "block";
    if (!isVisible) loadItems(id);
}

async function checkListDone(listId) {
    const snap = await getDocs(collection(db, "lists", listId, "items"));
    let items = [];
    snap.forEach(d => items.push(d.data()));
    const isDone = items.length > 0 && items.every(i => i.done === true);
    
    // Actualizar el cache local
    const listIndex = allLists.findIndex(l => l.id === listId);
    if(listIndex > -1) allLists[listIndex].isDone = isDone;

    applyFilters(); // Re-renderizar con filtros
}

async function loadItems(listId) {
    const listDiv = document.getElementById(`items-list-${listId}`);
    const snap = await getDocs(collection(db, "lists", listId, "items"));
    listDiv.innerHTML = "";
    let items = [];
    snap.forEach(itemDoc => items.push({ id: itemDoc.id, ...itemDoc.data() }));
    items.sort((a, b) => (a.name || a.text || "").localeCompare(b.name || b.text || "", undefined, {sensitivity: 'base'}));
    
    const ul = document.createElement('ul');
    items.forEach(item => {
        const itemName = item.name || item.text || "Task";
        const li = document.createElement('li');
        li.innerHTML = `
            <input type="checkbox" class="item-checkbox" ${item.done ? 'checked' : ''}>
            <span class="item-text ${item.done ? 'done-text' : ''}" id="text-${item.id}">${linkify(itemName)}</span>
            <div class="item-actions">
                <button class="btn-icon btn-edit-i">${ICON_EDIT}</button>
                <button class="btn-icon btn-delete-i">${ICON_DELETE}</button>
            </div>`;
        
        li.querySelector('.item-checkbox').onchange = async (e) => {
            await updateDoc(doc(db, "lists", listId, "items", item.id), { done: e.target.checked });
            checkListDone(listId);
        };
        li.querySelector('.btn-edit-i').onclick = (e) => { e.stopPropagation(); editItem(listId, item.id, itemName); };
        li.querySelector('.btn-delete-i').onclick = (e) => { e.stopPropagation(); deleteItem(listId, item.id); };
        ul.appendChild(li);
    });
    listDiv.appendChild(ul);
}

async function addItem(lId) {
    const input = document.getElementById(`input-${lId}`);
    if (!input.value.trim()) return;
    await addDoc(collection(db, "lists", lId, "items"), { name: input.value.trim(), done: false, timestamp: serverTimestamp() });
    input.value = "";
    loadItems(lId);
    checkListDone(lId);
}

async function deleteList(id) { if(confirm("Delete list?")) { await deleteDoc(doc(db, "lists", id)); fetchLists(currentUser.uid); } }
async function editList(id, old) { const n = prompt("Edit list name:", old); if(n && n!==old) { await updateDoc(doc(db, "lists", id), {name: n.trim()}); fetchLists(currentUser.uid); } }
async function deleteItem(lId, iId) { if(confirm("Delete task?")) { await deleteDoc(doc(db, "lists", lId, "items", iId)); loadItems(lId); checkListDone(lId); } }
async function editItem(lId, iId, old) { const n = prompt("Edit task:", old); if(n && n!==old) { await updateDoc(doc(db, "lists", lId, "items", iId), {name: n.trim()}); loadItems(lId); } }

exportBtn.onclick = async () => {
    const wb = XLSX.utils.book_new();
    const sortedExport = [...allLists].sort((a, b) => {
        if (a.isDone !== b.isDone) return a.isDone ? 1 : -1;
        return (a.name || "").localeCompare(b.name || "", undefined, {sensitivity: 'base'});
    });
    for (const list of sortedExport) {
        const snap = await getDocs(collection(db, "lists", list.id, "items"));
        let items = snap.docs.map(d => ({ Task: d.data().name || d.data().text, Status: d.data().done ? "Done" : "Pending" }));
        items.sort((a, b) => (a.Task || "").localeCompare(b.Task || "", undefined, {sensitivity: 'base'}));
        XLSX.utils.book_append_sheet(wb, XLSX.utils.json_to_sheet(items), list.name.substring(0,31));
    }
    XLSX.writeFile(wb, "Todoer_Export.xlsx");
};