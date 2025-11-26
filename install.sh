#!/bin/sh

echo "[1] Membuat folder aplikasi di /www..."
mkdir -p /www/bandwidth-monitor

echo "[2] Mengisi file HTML/JS kamu..."
cat << 'EOF' > /www/bandwidth-monitor/index.html
<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bandwidth Monitor - OpenWrt</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @keyframes slide-down {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-slide-down { animation: slide-down 0.3s ease-out; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .animate-spin { animation: spin 1s linear infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: .5; } }
        .animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
    </style>
</head>
<body class="bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 min-h-screen">
    <div id="app" class="p-4 md:p-6 max-w-7xl mx-auto"></div>

```
<script>
    const state = {
        users: [],
        searchTerm: '',
        sortBy: 'total',
        isRefreshing: false,
        lastUpdate: new Date(),
        selectedUser: null,
        notifications: [],
        filterStatus: 'all',
        routerInfo: {
            hostname: 'OpenWrt',
            uptime: '0h 0m',
            cpu: 0,
            ram: 0,
            wan: window.location.hostname,
            ping: 0
        }
    };

    const deviceIcons = {
        'LAPTOP': '💻', 'PC': '🖥️', 'DESKTOP': '🖥️',
        'IPHONE': '📱', 'ANDROID': '📱', 'SAMSUNG': '📱',
        'XIAOMI': '📱', 'IPAD': '📱', 'MACBOOK': '💻',
        'SMART': '📺', 'TV': '📺', 'WATCH': '⌚'
    };

    function getDeviceIcon(name) {
        const upperName = name.toUpperCase();
        for (let key in deviceIcons) {
            if (upperName.includes(key)) return deviceIcons[key];
        }
        return '📱';
    }

    function formatBytes(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return (bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i];
    }

    function formatDuration(minutes) {
        const hours = Math.floor(minutes / 60);
        const mins = minutes % 60;
        return `${hours}h ${mins}m`;
    }

    function addNotification(message, type = 'info') {
        const id = Date.now();
        state.notifications.unshift({ id, message, type });
        state.notifications = state.notifications.slice(0, 3);
        render();
        setTimeout(() => {
            state.notifications = state.notifications.filter(n => n.id !== id);
            render();
        }, 4000);
    }

    async function fetchData() {
        try {
            const response = await fetch('/cgi-bin/bandwidth-api');
            const data = await response.json();
            
            if (data.error) {
                addNotification('⚠️ ' + data.error, 'warning');
                return;
            }
            
            state.users = data.users || [];
            state.lastUpdate = new Date();
            render();
        } catch (error) {
            console.error('Error:', error);
            addNotification('❌ Failed to fetch data', 'error');
        }
    }

    async function handleRefresh() {
        state.isRefreshing = true;
        render();
        await fetchData();
        addNotification('📊 Data refreshed successfully', 'success');
        setTimeout(() => {
            state.isRefreshing = false;
            render();
        }, 1000);
    }

    function getFilteredAndSortedUsers() {
        let filtered = state.users.filter(user => {
            const matchSearch = user.name.toLowerCase().includes(state.searchTerm.toLowerCase()) ||
                user.ip.includes(state.searchTerm) || 
                user.mac.toLowerCase().includes(state.searchTerm.toLowerCase());
            const matchStatus = state.filterStatus === 'all' ||
                (state.filterStatus === 'online' && user.connected) ||
                (state.filterStatus === 'offline' && !user.connected);
            return matchSearch && matchStatus;
        });

        return filtered.sort((a, b) => {
            if (state.sortBy === 'download') return b.download - a.download;
            if (state.sortBy === 'upload') return b.upload - a.upload;
            return b.total - a.total;
        });
    }

    function render() {
        const sortedUsers = getFilteredAndSortedUsers();
        const connectedUsers = state.users.filter(u => u.connected);
        const totalDownload = connectedUsers.reduce((sum, u) => sum + u.download, 0);
        const totalUpload = connectedUsers.reduce((sum, u) => sum + u.upload, 0);

        document.getElementById('app').innerHTML = `
            <div class="mb-6">
                <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center gap-3">
                        <div class="bg-gradient-to-r from-purple-500 to-pink-500 p-3 rounded-xl shadow-xl">
                            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M17.778 8.222c-4.296-4.296-11.26-4.296-15.556 0A1 1 0 01.808 6.808c5.076-5.077 13.308-5.077 18.384 0a1 1 0 01-1.414 1.414zM14.95 11.05a7 7 0 00-9.9 0 1 1 0 01-1.414-1.414 9 9 0 0112.728 0 1 1 0 01-1.414 1.414zM12.12 13.88a3 3 0 00-4.242 0 1 1 0 01-1.415-1.415 5 5 0 017.072 0 1 1 0 01-1.415 1.415zM9 16a1 1 0 011-1h.01a1 1 0 110 2H10a1 1 0 01-1-1z"/>
                            </svg>
                        </div>
                        <div>
                            <h1 class="text-2xl md:text-3xl font-bold text-white">Bandwidth Monitor</h1>
                            <p class="text-purple-300 text-sm">${state.routerInfo.hostname} • OpenWrt Dashboard</p>
                        </div>
                    </div>
                    <button onclick="handleRefresh()" ${state.isRefreshing ? 'disabled' : ''} 
                        class="flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg transition-all backdrop-blur-sm shadow-lg">
                        <svg class="w-5 h-5 ${state.isRefreshing ? 'animate-spin' : ''}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                        </svg>
                        <span class="hidden md:inline">Refresh</span>
                    </button>
                </div>
                <div class="text-purple-300 text-xs md:text-sm flex items-center gap-3 flex-wrap">
                    <span>🕐 ${state.lastUpdate.toLocaleTimeString()}</span>
                    <span class="animate-pulse">🔄 Auto: 5s</span>
                    <span>📡 ${state.routerInfo.wan}</span>
                </div>
            </div>

            ${state.notifications.map(notif => `
                <div class="mb-4 flex items-center justify-between p-3 rounded-lg backdrop-blur-sm border animate-slide-down shadow-lg ${
                    notif.type === 'warning' ? 'bg-yellow-500/20 border-yellow-400/30 text-yellow-300' :
                    notif.type === 'error' ? 'bg-red-500/20 border-red-400/30 text-red-300' :
                    notif.type === 'success' ? 'bg-green-500/20 border-green-400/30 text-green-300' :
                    'bg-blue-500/20 border-blue-400/30 text-blue-300'
                }">
                    <span class="text-sm font-medium">${notif.message}</span>
                    <button onclick="state.notifications = state.notifications.filter(n => n.id !== ${notif.id}); render();">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                    </button>
                </div>
            `).join('')}

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <div class="bg-white/10 backdrop-blur-md rounded-xl p-5 border border-white/20 shadow-lg hover:shadow-2xl transition-all">
                    <div class="flex items-center justify-between mb-2">
                        <svg class="w-8 h-8 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/>
                        </svg>
                        <span class="text-3xl font-bold text-white">${connectedUsers.length}</span>
                    </div>
                    <p class="text-purple-300">Connected Users</p>
                </div>

                <div class="bg-white/10 backdrop-blur-md rounded-xl p-5 border border-white/20 shadow-lg hover:shadow-2xl transition-all">
                    <div class="flex items-center justify-between mb-2">
                        <svg class="w-8 h-8 text-green-400" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"/>
                        </svg>
                        <span class="text-xl font-bold text-white">${formatBytes(totalDownload)}</span>
                    </div>
                    <p class="text-purple-300 text-sm">Total Download</p>
                </div>

                <div class="bg-white/10 backdrop-blur-md rounded-xl p-5 border border-white/20 shadow-lg hover:shadow-2xl transition-all">
                    <div class="flex items-center justify-between mb-2">
                        <svg class="w-8 h-8 text-orange-400" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM6.293 6.707a1 1 0 010-1.414l3-3a1 1 0 011.414 0l3 3a1 1 0 01-1.414 1.414L11 5.414V13a1 1 0 11-2 0V5.414L7.707 6.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
                        </svg>
                        <span class="text-xl font-bold text-white">${formatBytes(totalUpload)}</span>
                    </div>
                    <p class="text-purple-300 text-sm">Total Upload</p>
                </div>

                <div class="bg-white/10 backdrop-blur-md rounded-xl p-5 border border-white/20 shadow-lg hover:shadow-2xl transition-all">
                    <div class="flex items-center justify-between mb-2">
                        <svg class="w-8 h-8 text-purple-400" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M2 6a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2V6zm0 6a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2v-2z" clip-rule="evenodd"/>
                        </svg>
                        <span class="text-xl font-bold text-white">${formatBytes(totalDownload + totalUpload)}</span>
                    </div>
                    <p class="text-purple-300 text-sm">Total Bandwidth</p>
                </div>
            </div>

            <div class="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/20 mb-4 shadow-lg">
                <div class="flex flex-col md:flex-row gap-3">
                    <div class="flex-1 relative">
                        <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 text-purple-300 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                        <input type="text" placeholder="Search by name, IP, or MAC..." 
                            value="${state.searchTerm}"
                            oninput="state.searchTerm = this.value; render();"
                            class="w-full bg-white/10 border border-white/20 rounded-lg pl-10 pr-4 py-2 text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500"/>
                    </div>
                    <select onchange="state.filterStatus = this.value; render();"
                        class="bg-white/10 border border-white/20 rounded-lg px-4 py-2 text-white focus:outline-none focus:ring-2 focus:ring-purple-500">
                        <option value="all" ${state.filterStatus === 'all' ? 'selected' : ''}>All Status</option>
                        <option value="online" ${state.filterStatus === 'online' ? 'selected' : ''}>Online</option>
                        <option value="offline" ${state.filterStatus === 'offline' ? 'selected' : ''}>Offline</option>
                    </select>
                    <select onchange="state.sortBy = this.value; render();"
                        class="bg-white/10 border border-white/20 rounded-lg px-4 py-2 text-white focus:outline-none focus:ring-2 focus:ring-purple-500">
                        <option value="total" ${state.sortBy === 'total' ? 'selected' : ''}>Sort by Total</option>
                        <option value="download" ${state.sortBy === 'download' ? 'selected' : ''}>Sort by Download</option>
                        <option value="upload" ${state.sortBy === 'upload' ? 'selected' : ''}>Sort by Upload</option>
                    </select>
                </div>
            </div>

            <div class="bg-white/10 backdrop-blur-md rounded-xl border border-white/20 overflow-hidden shadow-lg mb-6">
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-white/5">
                            <tr>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Device</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">IP Address</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Download</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Upload</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Total</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Signal</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Duration</th>
                                <th class="px-4 py-3 text-left text-purple-300 font-semibold text-sm">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/10">
                            ${sortedUsers.map(user => `
                                <tr class="hover:bg-white/5 transition-colors">
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2">
                                            <div class="w-2 h-2 rounded-full ${user.connected ? 'bg-green-400 animate-pulse' : 'bg-gray-400'}"></div>
                                            <span class="text-xl">${getDeviceIcon(user.name)}</span>
                                            <div>
                                                <p class="text-white font-semibold text-sm">${user.name}</p>
                                                <p class="text-purple-300 text-xs">${user.mac}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-white text-sm">${user.ip}</td>
                                    <td class="px-4 py-3 text-green-400 text-sm">${formatBytes(user.download)}</td>
                                    <td class="px-4 py-3 text-orange-400 text-sm">${formatBytes(user.upload)}</td>
                                    <td class="px-4 py-3 text-white font-bold text-sm">${formatBytes(user.total)}</td>
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2">
                                            <div class="w-16 bg-white/10 rounded-full h-2">
                                                <div class="h-2 rounded-full ${user.signal > 80 ? 'bg-green-400' : user.signal > 60 ? 'bg-yellow-400' : 'bg-red-400'}"
                                                    style="width: ${user.signal}%"></div>
                                            </div>
                                            <span class="text-white text-xs">${user.signal}%</span>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-white text-sm">${formatDuration(user.duration)}</td>
                                    <td class="px-4 py-3">
                                        <button onclick='state.selectedUser = ${JSON.stringify(user).replace(/'/g, "\\'")}; render();'
                                            class="p-2 bg-blue-500/20 hover:bg-blue-500/40 text-blue-300 rounded-lg transition-all">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                            </svg>
                                        </button>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="text-center">
                <p class="text-purple-300 text-sm mb-2">Showing ${sortedUsers.length} of ${state.users.length} devices</p>
                <div class="bg-white/5 backdrop-blur-md rounded-lg p-4 border border-white/10">
                    <p class="text-white font-bold mb-1">OpenWrt Bandwidth Monitor</p>
                    <p class="text-purple-300 text-xs">© 2025 • Powered by OpenWrt</p>
                    <p class="text-purple-400 text-sm font-semibold mt-1">Created by PakRT</p>
                </div>
            </div>

            ${state.selectedUser ? `
                <div class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
                    <div class="bg-slate-800 rounded-xl p-6 max-w-2xl w-full border border-white/20 shadow-2xl">
                        <div class="flex items-center justify-between mb-6">
                            <div class="flex items-center gap-3">
                                <span class="text-4xl">${getDeviceIcon(state.selectedUser.name)}</span>
                                <h3 class="text-2xl font-bold text-white">Device Details</h3>
                            </div>
                            <button onclick="state.selectedUser = null; render();" class="text-white hover:text-purple-300">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                                </svg>
                            </button>
                        </div>
                        <div class="space-y-4">
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <p class="text-purple-300 text-sm">Device Name</p>
                                    <p class="text-white font-semibold text-lg">${state.selectedUser.name}</p>
                                </div>
                                <div>
                                    <p class="text-purple-300 text-sm">IP Address</p>
                                    <p class="text-white font-semibold text-lg">${state.selectedUser.ip}</p>
                                </div>
                                <div>
                                    <p class="text-purple-300 text-sm">MAC Address</p>
                                    <p class="text-white font-semibold">${state.selectedUser.mac}</p>
                                </div>
                                <div>
                                    <p class="text-purple-300 text-sm">Status</p>
                                    <p class="font-semibold ${state.selectedUser.connected ? 'text-green-400' : 'text-gray-400'}">
                                        ${state.selectedUser.connected ? 'Online' : 'Offline'}
                                    </p>
                                </div>
                            </div>
                            <div class="bg-white/5 rounded-lg p-4 space-y-3">
                                <div class="flex justify-between">
                                    <span class="text-purple-300">Download:</span>
                                    <span class="text-green-400 font-bold">${formatBytes(state.selectedUser.download)}</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-purple-300">Upload:</span>
                                    <span class="text-orange-400 font-bold">${formatBytes(state.selectedUser.upload)}</span>
                                </div>
                                <div class="flex justify-between border-t border-white/10 pt-3">
                                    <span class="text-purple-300">Total Usage:</span>
                                    <span class="text-white font-bold text-lg">${formatBytes(state.selectedUser.total)}</span>
                                </div>
                            </div>
                            <div class="grid grid-cols-2 gap-4">
                                <div class="bg-white/5 rounded-lg p-4">
                                    <p class="text-purple-300 text-sm mb-2">Signal Strength</p>
                                    <div class="flex items-center gap-2">
                                        <div class="flex-1 bg-white/10 rounded-full h-3">
                                            <div class="h-3 rounded-full ${state.selectedUser.signal > 80 ? 'bg-green-400' : state.selectedUser.signal > 60 ? 'bg-yellow-400' : 'bg-red-400'}"
                                                style="width: ${state.selectedUser.signal}%"></div>
                                        </div>
                                        <span class="text-white font-bold">${state.selectedUser.signal}%</span>
                                    </div>
                                </div>
                                <div class="bg-white/5 rounded-lg p-4">
                                    <p class="text-purple-300 text-sm mb-2">Connected Time</p>
                                    <p class="text-white font-bold">${formatDuration(state.selectedUser.duration)}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            ` : ''}
        `;
    }

    // Initial render and auto-refresh
    fetchData();
    setInterval(fetchData, 5000);
</script>
```

</body>
</html>

EOF

echo "[3] Membuat controller LuCI..."
mkdir -p /usr/lib/lua/luci/controller

cat << 'EOF' > /usr/lib/lua/luci/controller/bandwidth-monitor.lua
module("luci.controller.bandwidth-monitor", package.seeall)

function index()
    entry({"admin", "services", "bandwidth-monitor"}, call("action_bandwidth_monitor"), _("Bandwidth Monitor"), 20)
end

function action_bandwidth_monitor()
    luci.http.redirect("/bandwidth-monitor/index.html")
end
EOF

echo "[4] Membuat ACL..."
mkdir -p /usr/share/rpcd/acl.d

cat << 'EOF' > /usr/share/rpcd/acl.d/luci-app-bandwidth-monitor.json
{
  "luci-app-bandwidth-monitor": {
    "description": "Bandwidth Monitor",
    "read": { "uci": ["*"] },
    "write": { "uci": ["*"] }
  }
}
EOF

echo "[5] Restart rpcd & uhttpd..."
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart

echo "===================================================="
echo "  ✔ Install selesai!"
echo "  ✔ Menu muncul di: Services → Bandwidth Monitor"
echo "  ✔ File HTML ada di: /www/bandwidth-monitor/index.html"
echo "===================================================="