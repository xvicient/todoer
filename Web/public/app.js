/**
 * Todoer App Logic
 */
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getFirestore, collection, query, where, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
import { firebaseConfig } from './config.js';

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
const provider = new GoogleAuthProvider();

// DOM Elements
const displayEl = document.getElementById('data-display');
const btnLogin = document.getElementById('btn-login');
const btnLogout = document.getElementById('btn-logout');
const userInfoSection = document.getElementById('user-info');
const appContent = document.getElementById('app-content');
const loginPrompt = document.getElementById('login-prompt');
const exportBtn = document.getElementById('export-btn');
const btnNewList = document.getElementById('btn-new-list');

const ICON_EDIT = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4L18.5 2.5z"></path></svg>`;
const ICON_DELETE = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>`;

let currentUser = null;
let allLists = [];

// Authentication Logic
onAuthStateChanged(auth, (user) => {
    if (user) {
        currentUser = user;
        loginPrompt.style.display = 'none';
        appContent.style.display = 'block';
        userInfoSection.style.display = 'flex'; // Shows Export and Logout
        fetchLists(user.uid);
    } else {
        currentUser = null;
        loginPrompt.style.display = 'block';
        appContent.style.display = 'none';
        userInfoSection.style.display = 'none'; // Hides Export and Logout
    }
});

if(btnLogin) btnLogin.onclick = () => signInWithPopup(auth, provider);
if(btnLogout) btnLogout.onclick = () => signOut(auth);

// CRUD Operations (Sorted Alphabetically)
btnNewList.onclick = async () => {
    const listName = prompt("New List Name:");
    if (!listName) return;
    await addDoc(collection(db, "lists"), { name: listName.trim(), uid: [currentUser.uid], timestamp: serverTimestamp() });
    fetchLists(currentUser.uid);
};

async function fetchLists(uid) {
    const q = query(collection(db, "lists"), where("uid", "array-contains", uid));
    const snap = await getDocs(q);
    displayEl.innerHTML = "";
    allLists = [];
    
    snap.forEach(d => allLists.push({ id: d.id, ...d.data() }));
    allLists.sort((a, b) => (a.name || "").localeCompare(b.name || "", undefined, {sensitivity: 'base'}));
    
    allLists.forEach(list => {
        const card = document.createElement('div');
        card.className = 'list-card';
        card.innerHTML = `
            <div class="list-header">
                <span class="list-title" id="title-${list.id}">${list.name || 'List'}</span>
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

        document.getElementById(`title-${list.id}`).onclick = () => toggleItems(list.id);
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
            <span class="item-text ${item.done ? 'done-text' : ''}" id="text-${item.id}">${itemName}</span>
            <div class="item-actions">
                <button class="btn-icon btn-edit-i">${ICON_EDIT}</button>
                <button class="btn-icon btn-delete-i">${ICON_DELETE}</button>
            </div>`;

        li.querySelector('.item-checkbox').onchange = (e) => toggleDone(listId, item.id, e.target.checked);
        li.querySelector('.btn-edit-i').onclick = () => editItem(listId, item.id, itemName);
        li.querySelector('.btn-delete-i').onclick = () => deleteItem(listId, item.id);
        ul.appendChild(li);
    });
    listDiv.appendChild(ul);
}

async function toggleDone(lId, iId, status) {
    await updateDoc(doc(db, "lists", lId, "items", iId), { done: status });
    document.getElementById(`text-${iId}`).classList.toggle('done-text', status);
}

async function addItem(lId) {
    const input = document.getElementById(`input-${lId}`);
    if (!input.value.trim()) return;
    await addDoc(collection(db, "lists", lId, "items"), { name: input.value.trim(), done: false, timestamp: serverTimestamp() });
    input.value = "";
    loadItems(lId);
}

// Helpers
async function deleteList(id) { if(confirm("Delete list?")) { await deleteDoc(doc(db, "lists", id)); fetchLists(currentUser.uid); } }
async function editList(id, old) { const n = prompt("Edit list name:", old); if(n && n!==old) { await updateDoc(doc(db, "lists", id), {name: n.trim()}); fetchLists(currentUser.uid); } }
async function deleteItem(lId, iId) { if(confirm("Delete task?")) { await deleteDoc(doc(db, "lists", lId, "items", iId)); loadItems(lId); } }
async function editItem(lId, iId, old) { const n = prompt("Edit task:", old); if(n && n!==old) { await updateDoc(doc(db, "lists", lId, "items", iId), {name: n.trim()}); loadItems(lId); } }

// Excel Export
exportBtn.onclick = async () => {
    const wb = XLSX.utils.book_new();
    const sortedLists = [...allLists].sort((a, b) => (a.name || "").localeCompare(b.name || "", undefined, {sensitivity: 'base'}));
    for (const list of sortedLists) {
        const snap = await getDocs(collection(db, "lists", list.id, "items"));
        let items = snap.docs.map(d => ({ Task: d.data().name || d.data().text, Status: d.data().done ? "Done" : "Pending" }));
        items.sort((a, b) => (a.Task || "").localeCompare(b.Task || "", undefined, {sensitivity: 'base'}));
        XLSX.utils.book_append_sheet(wb, XLSX.utils.json_to_sheet(items), list.name.substring(0,31));
    }
    XLSX.writeFile(wb, "Todoer_Export.xlsx");
};