// Expense Tracker Web App
class ExpenseTracker {
    constructor() {
        this.expenses = this.loadExpenses();
        this.budgets = this.loadBudgets();
        this.currentUser = null;
        this.charts = {};
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.initializeApp();
        this.setDefaultDate();
    }

    setupEventListeners() {
        // Auth tabs
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.switchAuthTab(e.target.dataset.tab));
        });

        // Auth forms
        document.getElementById('loginForm').addEventListener('submit', (e) => this.handleLogin(e));
        document.getElementById('registerForm').addEventListener('submit', (e) => this.handleRegister(e));

        // Password toggle
        document.querySelectorAll('.toggle-password').forEach(btn => {
            btn.addEventListener('click', (e) => this.togglePassword(e.target));
        });

        // Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => this.switchPage(e.target.closest('.nav-item').dataset.page));
        });

        // Expense modals
        document.getElementById('addExpenseBtn').addEventListener('click', () => this.openExpenseModal());
        document.getElementById('addExpenseBtn2').addEventListener('click', () => this.openExpenseModal());
        document.getElementById('closeExpenseModal').addEventListener('click', () => this.closeExpenseModal());
        document.getElementById('cancelExpense').addEventListener('click', () => this.closeExpenseModal());
        document.getElementById('expenseForm').addEventListener('submit', (e) => this.addExpense(e));

        // Filters
        document.getElementById('categoryFilter').addEventListener('change', () => this.filterExpenses());
        document.getElementById('dateFilter').addEventListener('change', () => this.filterExpenses());

        // Budget button
        document.getElementById('addBudgetBtn').addEventListener('click', () => this.addBudget());

        // Modal backdrop click
        document.getElementById('expenseModal').addEventListener('click', (e) => {
            if (e.target === e.currentTarget) {
                this.closeExpenseModal();
            }
        });
    }

    switchAuthTab(tab) {
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.tab === tab);
        });
        
        document.querySelectorAll('.auth-form').forEach(form => {
            form.classList.toggle('hidden', form.id !== `${tab}Form`);
        });

        // Clear errors
        document.getElementById('loginError').textContent = '';
        document.getElementById('registerError').textContent = '';
    }

    handleLogin(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        const username = formData.get('username') || e.target.querySelector('input[type="text"]').value;
        const password = formData.get('password') || e.target.querySelector('input[type="password"]').value;

        if (!username || !password) {
            document.getElementById('loginError').textContent = '⚠ Please fill in all fields';
            return;
        }

        // Simulate login success
        this.currentUser = username;
        this.showMainApp();
    }

    handleRegister(e) {
        e.preventDefault();
        const formData = new FormData(e.target);
        const username = formData.get('username') || e.target.querySelector('input[type="text"]').value;
        const email = formData.get('email') || e.target.querySelector('input[type="email"]').value;
        const password = formData.get('password') || e.target.querySelectorAll('input[type="password"]')[0].value;

        if (!username || !email || !password) {
            document.getElementById('registerError').textContent = '⚠ Please fill in all fields';
            return;
        }

        // Simulate registration success
        this.currentUser = username;
        this.showMainApp();
    }

    showMainApp() {
        document.getElementById('landingPage').classList.remove('active');
        document.getElementById('mainApp').classList.add('active');
        this.updateDashboard();
        this.initializeCharts();
    }

    switchPage(page) {
        // Update navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.toggle('active', item.dataset.page === page);
        });

        // Update pages
        document.querySelectorAll('.app-page').forEach(appPage => {
            appPage.classList.toggle('active', appPage.id === page);
        });

        // Page-specific updates
        switch(page) {
            case 'dashboard':
                this.updateDashboard();
                break;
            case 'expenses':
                this.displayExpenses();
                break;
            case 'analytics':
                this.updateAnalytics();
                break;
            case 'budgets':
                this.displayBudgets();
                break;
        }
    }

    togglePassword(button) {
        const input = button.previousElementSibling;
        const icon = button.querySelector('i');
        
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    openExpenseModal() {
        document.getElementById('expenseModal').classList.add('active');
    }

    closeExpenseModal() {
        document.getElementById('expenseModal').classList.remove('active');
        document.getElementById('expenseForm').reset();
    }

    addExpense(e) {
        e.preventDefault();
        
        const description = document.getElementById('expenseDescription').value;
        const amount = parseFloat(document.getElementById('expenseAmount').value);
        const category = document.getElementById('expenseCategory').value;
        const date = document.getElementById('expenseDate').value;

        const expense = {
            id: Date.now(),
            description,
            amount,
            category,
            date,
            timestamp: new Date().toISOString()
        };

        this.expenses.push(expense);
        this.saveExpenses();
        this.closeExpenseModal();
        this.updateDashboard();
        this.displayExpenses();
        this.updateAnalytics();
    }

    filterExpenses() {
        const category = document.getElementById('categoryFilter').value;
        const date = document.getElementById('dateFilter').value;
        
        let filtered = this.expenses;
        
        if (category) {
            filtered = filtered.filter(expense => expense.category === category);
        }
        
        if (date) {
            filtered = filtered.filter(expense => expense.date === date);
        }
        
        this.displayExpensesList(filtered);
    }

    displayExpenses() {
        this.displayExpensesList(this.expenses);
    }

    displayExpensesList(expenses) {
        const container = document.getElementById('allExpenses');
        container.innerHTML = '';

        const sortedExpenses = [...expenses].sort((a, b) => new Date(b.date) - new Date(a.date));

        sortedExpenses.forEach(expense => {
            const expenseElement = this.createExpenseElement(expense);
            container.appendChild(expenseElement);
        });
    }

    createExpenseElement(expense) {
        const div = document.createElement('div');
        div.className = 'expense-item';
        
        const categoryColors = {
            food: '#FF6B6B',
            transport: '#4ECDC4',
            shopping: '#45B7D1',
            entertainment: '#96CEB4',
            bills: '#FFEAA7',
            health: '#DDA0DD',
            other: '#95A5A6'
        };

        const categoryIcons = {
            food: 'fa-utensils',
            transport: 'fa-car',
            shopping: 'fa-shopping-bag',
            entertainment: 'fa-film',
            bills: 'fa-file-invoice',
            health: 'fa-heartbeat',
            other: 'fa-ellipsis-h'
        };

        div.innerHTML = `
            <div class="expense-info">
                <h4>${expense.description}</h4>
                <div class="expense-meta">
                    <span><i class="fas ${categoryIcons[expense.category]}"></i> ${this.getCategoryName(expense.category)}</span>
                    <span><i class="fas fa-calendar"></i> ${new Date(expense.date).toLocaleDateString()}</span>
                </div>
            </div>
            <div class="expense-amount">-$${expense.amount.toFixed(2)}</div>
        `;

        return div;
    }

    updateDashboard() {
        this.updateSummaryCards();
        this.displayRecentTransactions();
        this.updateExpenseChart();
    }

    updateSummaryCards() {
        const totalExpenses = this.expenses.reduce((sum, expense) => sum + expense.amount, 0);
        const totalIncome = 5000; // Simulated income
        const balance = totalIncome - totalExpenses;

        document.getElementById('totalBalance').textContent = `$${balance.toFixed(2)}`;
        document.getElementById('totalIncome').textContent = `$${totalIncome.toFixed(2)}`;
        document.getElementById('totalExpenses').textContent = `$${totalExpenses.toFixed(2)}`;
    }

    displayRecentTransactions() {
        const container = document.getElementById('recentTransactions');
        container.innerHTML = '';

        const recentExpenses = this.expenses
            .sort((a, b) => new Date(b.date) - new Date(a.date))
            .slice(0, 5);

        recentExpenses.forEach(expense => {
            const transactionElement = this.createTransactionElement(expense);
            container.appendChild(transactionElement);
        });

        if (recentExpenses.length === 0) {
            container.innerHTML = '<p style="text-align: center; color: var(--fb-gray);">No recent transactions</p>';
        }
    }

    createTransactionElement(expense) {
        const div = document.createElement('div');
        div.className = 'transaction-item';

        const categoryColors = {
            food: '#FF6B6B',
            transport: '#4ECDC4',
            shopping: '#45B7D1',
            entertainment: '#96CEB4',
            bills: '#FFEAA7',
            health: '#DDA0DD',
            other: '#95A5A6'
        };

        const categoryIcons = {
            food: 'fa-utensils',
            transport: 'fa-car',
            shopping: 'fa-shopping-bag',
            entertainment: 'fa-film',
            bills: 'fa-file-invoice',
            health: 'fa-heartbeat',
            other: 'fa-ellipsis-h'
        };

        div.innerHTML = `
            <div class="transaction-info">
                <div class="transaction-icon" style="background-color: ${categoryColors[expense.category]}20;">
                    <i class="fas ${categoryIcons[expense.category]}" style="color: ${categoryColors[expense.category]};"></i>
                </div>
                <div class="transaction-details">
                    <h4>${expense.description}</h4>
                    <p>${this.getCategoryName(expense.category)} • ${new Date(expense.date).toLocaleDateString()}</p>
                </div>
            </div>
            <div class="transaction-amount">
                <span class="amount expense">-$${expense.amount.toFixed(2)}</span>
            </div>
        `;

        return div;
    }

    initializeCharts() {
        this.updateExpenseChart();
        this.updateAnalytics();
    }

    updateExpenseChart() {
        const ctx = document.getElementById('expenseChart');
        if (!ctx) return;

        if (this.charts.expense) {
            this.charts.expense.destroy();
        }

        const categoryData = this.getCategoryData();
        
        this.charts.expense = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: categoryData.labels,
                datasets: [{
                    data: categoryData.data,
                    backgroundColor: [
                        '#FF6B6B',
                        '#4ECDC4',
                        '#45B7D1',
                        '#96CEB4',
                        '#FFEAA7',
                        '#DDA0DD',
                        '#95A5A6'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#E4E6EB',
                            padding: 10
                        }
                    }
                }
            }
        });
    }

    updateAnalytics() {
        this.updateMonthlyChart();
        this.updateCategoryChart();
        this.updateStatistics();
    }

    updateMonthlyChart() {
        const ctx = document.getElementById('monthlyChart');
        if (!ctx) return;

        if (this.charts.monthly) {
            this.charts.monthly.destroy();
        }

        const monthlyData = this.getMonthlyData();
        
        this.charts.monthly = new Chart(ctx, {
            type: 'line',
            data: {
                labels: monthlyData.labels,
                datasets: [{
                    label: 'Monthly Expenses',
                    data: monthlyData.data,
                    borderColor: '#1877F2',
                    backgroundColor: 'rgba(24, 119, 242, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: {
                            color: '#E4E6EB'
                        }
                    }
                },
                scales: {
                    y: {
                        ticks: {
                            color: '#E4E6EB'
                        },
                        grid: {
                            color: '#3A3B3C'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#E4E6EB'
                        },
                        grid: {
                            color: '#3A3B3C'
                        }
                    }
                }
            }
        });
    }

    updateCategoryChart() {
        const ctx = document.getElementById('categoryChart');
        if (!ctx) return;

        if (this.charts.category) {
            this.charts.category.destroy();
        }

        const categoryData = this.getCategoryData();
        
        this.charts.category = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: categoryData.labels,
                datasets: [{
                    label: 'Expenses by Category',
                    data: categoryData.data,
                    backgroundColor: [
                        '#FF6B6B',
                        '#4ECDC4',
                        '#45B7D1',
                        '#96CEB4',
                        '#FFEAA7',
                        '#DDA0DD',
                        '#95A5A6'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        ticks: {
                            color: '#E4E6EB'
                        },
                        grid: {
                            color: '#3A3B3C'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#E4E6EB'
                        },
                        grid: {
                            color: '#3A3B3C'
                        }
                    }
                }
            }
        });
    }

    updateStatistics() {
        const totalExpenses = this.expenses.reduce((sum, expense) => sum + expense.amount, 0);
        const avgDaily = this.expenses.length > 0 ? totalExpenses / 30 : 0; // Assuming 30 days
        const highestExpense = this.expenses.length > 0 ? Math.max(...this.expenses.map(e => e.amount)) : 0;
        const topCategory = this.getTopCategory();
        
        document.getElementById('avgDaily').textContent = `$${avgDaily.toFixed(2)}`;
        document.getElementById('highestExpense').textContent = `$${highestExpense.toFixed(2)}`;
        document.getElementById('topCategory').textContent = topCategory;
        document.getElementById('totalTransactions').textContent = this.expenses.length;
    }

    getCategoryData() {
        const categories = {};
        
        this.expenses.forEach(expense => {
            if (!categories[expense.category]) {
                categories[expense.category] = 0;
            }
            categories[expense.category] += expense.amount;
        });

        return {
            labels: Object.keys(categories).map(cat => this.getCategoryName(cat)),
            data: Object.values(categories)
        };
    }

    getMonthlyData() {
        const monthly = {};
        const currentYear = new Date().getFullYear();
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        // Initialize with zeros
        months.forEach(month => {
            monthly[month] = 0;
        });

        this.expenses.forEach(expense => {
            const date = new Date(expense.date);
            if (date.getFullYear() === currentYear) {
                const month = months[date.getMonth()];
                monthly[month] += expense.amount;
            }
        });

        return {
            labels: months,
            data: Object.values(monthly)
        };
    }

    getTopCategory() {
        const categories = {};
        
        this.expenses.forEach(expense => {
            if (!categories[expense.category]) {
                categories[expense.category] = 0;
            }
            categories[expense.category] += expense.amount;
        });

        if (Object.keys(categories).length === 0) return '-';
        
        const topCategory = Object.entries(categories).reduce((a, b) => a[1] > b[1] ? a : b);
        return this.getCategoryName(topCategory[0]);
    }

    getCategoryName(category) {
        const names = {
            food: 'Food & Dining',
            transport: 'Transportation',
            shopping: 'Shopping',
            entertainment: 'Entertainment',
            bills: 'Bills & Utilities',
            health: 'Healthcare',
            other: 'Other'
        };
        return names[category] || category;
    }

    displayBudgets() {
        const container = document.getElementById('budgetsList');
        container.innerHTML = '';

        if (this.budgets.length === 0) {
            container.innerHTML = '<p style="text-align: center; color: var(--fb-gray);">No budgets set. Create your first budget!</p>';
            return;
        }

        this.budgets.forEach(budget => {
            const budgetElement = this.createBudgetElement(budget);
            container.appendChild(budgetElement);
        });
    }

    createBudgetElement(budget) {
        const div = document.createElement('div');
        div.className = 'budget-card';

        const spent = this.getBudgetSpent(budget.category);
        const percentage = (spent / budget.amount) * 100;
        const progressClass = percentage > 90 ? 'danger' : percentage > 70 ? 'warning' : '';

        div.innerHTML = `
            <div class="budget-header">
                <div class="budget-name">${this.getCategoryName(budget.category)}</div>
                <div class="budget-amount">$${spent.toFixed(2)} / $${budget.amount.toFixed(2)}</div>
            </div>
            <div class="budget-progress">
                <div class="progress-bar">
                    <div class="progress-fill ${progressClass}" style="width: ${Math.min(percentage, 100)}%"></div>
                </div>
            </div>
            <div class="budget-details">
                <span>${percentage.toFixed(1)}% used</span>
                <span>$${(budget.amount - spent).toFixed(2)} remaining</span>
            </div>
        `;

        return div;
    }

    getBudgetSpent(category) {
        return this.expenses
            .filter(expense => expense.category === category)
            .reduce((sum, expense) => sum + expense.amount, 0);
    }

    addBudget() {
        const category = prompt('Enter category (food, transport, shopping, entertainment, bills, health, other):');
        const amount = parseFloat(prompt('Enter budget amount:'));

        if (category && amount && !isNaN(amount)) {
            const budget = {
                id: Date.now(),
                category,
                amount,
                createdAt: new Date().toISOString()
            };

            this.budgets.push(budget);
            this.saveBudgets();
            this.displayBudgets();
        }
    }

    setDefaultDate() {
        const today = new Date().toISOString().split('T')[0];
        const dateInput = document.getElementById('expenseDate');
        if (dateInput) {
            dateInput.value = today;
        }
    }

    // Storage methods
    loadExpenses() {
        const stored = localStorage.getItem('expenses');
        return stored ? JSON.parse(stored) : this.getDefaultExpenses();
    }

    saveExpenses() {
        localStorage.setItem('expenses', JSON.stringify(this.expenses));
    }

    loadBudgets() {
        const stored = localStorage.getItem('budgets');
        return stored ? JSON.parse(stored) : this.getDefaultBudgets();
    }

    saveBudgets() {
        localStorage.setItem('budgets', JSON.stringify(this.budgets));
    }

    getDefaultExpenses() {
        return [
            {
                id: 1,
                description: 'Grocery Shopping',
                amount: 125.50,
                category: 'food',
                date: new Date().toISOString().split('T')[0],
                timestamp: new Date().toISOString()
            },
            {
                id: 2,
                description: 'Gas Station',
                amount: 45.00,
                category: 'transport',
                date: new Date(Date.now() - 86400000).toISOString().split('T')[0],
                timestamp: new Date(Date.now() - 86400000).toISOString()
            },
            {
                id: 3,
                description: 'Netflix Subscription',
                amount: 15.99,
                category: 'entertainment',
                date: new Date(Date.now() - 172800000).toISOString().split('T')[0],
                timestamp: new Date(Date.now() - 172800000).toISOString()
            }
        ];
    }

    getDefaultBudgets() {
        return [
            {
                id: 1,
                category: 'food',
                amount: 500,
                createdAt: new Date().toISOString()
            },
            {
                id: 2,
                category: 'transport',
                amount: 200,
                createdAt: new Date().toISOString()
            },
            {
                id: 3,
                category: 'entertainment',
                amount: 100,
                createdAt: new Date().toISOString()
            }
        ];
    }

    initializeApp() {
        // Check if user is already logged in (for demo purposes)
        if (localStorage.getItem('currentUser')) {
            this.currentUser = localStorage.getItem('currentUser');
            this.showMainApp();
        }
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new ExpenseTracker();
});
