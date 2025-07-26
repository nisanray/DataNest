# 📋 DataNest Features & Roadmap

## ✅ Currently Implemented Features

### 1. Offline-First Data Storage
- **What it is:** All user data (sections, fields, records) is stored locally using Hive for instant access and reliability.
- **How to use:**
  - You can use DataNest without an internet connection. All changes are saved locally and will sync to the cloud when you go online.
  - No manual action is needed—offline/online transitions are handled automatically.

### 2. Cloud Sync with Firestore
- **What it is:** Automatic sync between local Hive data and Firestore.
- **How to use:**
  - When you log in, your data is fetched from Firestore and saved to your device.
  - Any changes you make (add/edit/delete) are saved locally and marked as unsynced.
  - When you regain connectivity, all unsynced changes are uploaded to Firestore and marked as synced.
  - You can trigger a manual sync by tapping the sync icon in the app bar.

### 3. Dynamic Data Modeling
- **What it is:** Users can create unlimited sections (categories), each with custom fields (text, number, date, etc.).
- **How to use:**
  - Tap the "+" button or "New Section" in the drawer to create a new section.
  - Choose a name, icon, and color for your section.
  - Add fields to your section by specifying the field type (text, number, date, etc.) and options (required, unique, etc.).
  - Fields can be reordered and edited at any time.

### 4. Dynamic Forms & Record Management
- **What it is:** Forms are generated dynamically based on user-defined fields. You can add, edit, and delete records for any section.
- **How to use:**
  - Select a section from the drawer or dashboard.
  - Go to the "Records" tab to view, add, or edit records.
  - Tap the "+" button to add a new record. The form will match your custom fields.
  - Edit or delete records using the action buttons on each record card.

### 5. Modern UI/UX
- **What it is:** Responsive, Material Design UI with dark mode, dynamic navigation, and tabs for records, fields, and settings.
- **How to use:**
  - Use the drawer/sidebar to navigate between sections.
  - Switch between "Records", "Fields", and "Settings" tabs in each section.
  - The UI adapts to your device and theme preferences automatically.

### 6. Debugging & Observability
- **What it is:** Extensive `debugPrint` instrumentation throughout the codebase for easy debugging and tracing of all sync and data actions.
- **How to use:**
  - Run the app in debug mode (e.g., with `flutter run`).
  - Open your IDE or terminal's debug console to see detailed logs of all user actions, sync events, and data changes.
  - Use these logs to diagnose issues or understand app behavior.

---

## 🛠️ How to Use DataNest (Step-by-Step)

### 1. Getting Started
- **Install dependencies:**
  ```sh
  flutter pub get
  ```
- **Generate Hive adapters:**
  ```sh
  flutter packages pub run build_runner build
  ```
- **Run the app:**
  ```sh
  flutter run
  ```

### 2. Authentication & Sync
- **Sign in or register** with your email.
- On login, your data is automatically fetched from Firestore and saved to your device.
- You can use the app offline; all changes will sync when you reconnect.

### 3. Creating and Managing Sections
- Tap the "+" button or "New Section" in the drawer.
- Enter a section name, pick an icon and color, and save.
- Your new section appears in the drawer and dashboard.

### 4. Adding and Customizing Fields
- Select a section and go to the "Fields" tab.
- Tap "+" to add a new field.
- Choose the field type (text, number, date, etc.) and set options (required, unique, etc.).
- Fields can be edited or reordered at any time.

### 5. Adding, Editing, and Deleting Records
- Go to the "Records" tab in any section.
- Tap "+" to add a new record. The form will match your custom fields.
- Edit or delete records using the action buttons on each record card.

### 6. Syncing Data
- Data is synced automatically in the background.
- To force a sync, tap the sync icon in the app bar.
- The sync status is shown in the debug console.

### 7. Debugging and Observability
- Run the app in debug mode to see all debugPrint logs.
- Logs include user actions, sync events, and data changes for easy troubleshooting.

---

## 🚀 Future Features & Detailed Plans


### 1. 📝 Tasks with Reminders, Subtasks, and Time Limits (**To Implement**)
- **By Default Section for Task Managing:**
  - User can create tasks, each with optional subtasks.
  - Each task and subtask can have an optional reminder.
  - Each task and subtask can have an optional time limit.
  - UI: Create/edit tasks and subtasks, set reminders and time limits, expand/collapse subtasks.
  - Reminders: Use local notifications for reminders and due dates.
  - Sync: Store tasks in Hive and sync with Firestore, similar to sections/records. Reminders are scheduled locally.
  - **Status:** Not yet implemented.

---

## ✅ Currently Implemented Features (Summary)

- Offline-first data storage (Hive)
- Cloud sync with Firestore
- Dynamic data modeling (sections, fields)
- Dynamic forms & record management
- Modern, responsive UI/UX (Material Design, dark mode)
- Debugging & observability (debugPrint logs)
- Section/field/record CRUD
- Automatic and manual sync
- Field types: text, number, date, etc.
- Section/field/record reordering and editing

## 🚧 Features To Implement (Roadmap)

- Tasks with reminders, subtasks, and time limits (see above)
- Collaboration & sharing (multi-user, real-time, permissions)
- Advanced search & filtering
- Calendar & timeline views
- Data export/import (JSON, CSV)
- Custom field types & plugins
- Notifications & reminders (in-app, push)
- Security & access control (advanced auth, roles)
- Mobile/Desktop/Web parity
- Analytics & reporting (charts, dashboards)
- Templates, AI suggestions, widgets, QR/barcode, API integrations

---

### 2. 👥 Collaboration & Sharing
- Invite other users to shared sections or tasks.
- Real-time multi-user editing and sync.
- Role-based access and permissions.

### 3. 🔍 Advanced Search & Filtering
- Search records by any field or value.
- Filter by section, field type, date range, etc.
- Save and reuse custom filters.

### 4. 📅 Calendar & Timeline Views
- Visualize records and tasks on a calendar or timeline.
- Drag-and-drop to reschedule tasks or events.

### 5. 📦 Data Export & Import
- Export sections, fields, and records as JSON or CSV.
- Import data from other sources.

### 6. 🧩 Custom Field Types & Plugins
- Add new field types (e.g., Kanban, checklist, rating, etc.).
- Support for user-defined plugins and integrations.

### 7. 🔔 Notifications & Reminders
- In-app and push notifications for reminders, due dates, and collaboration events.

### 8. 🛡️ Security & Access Control
- Advanced authentication (Google, email, etc.).
- Role-based permissions for teams and shared data.

### 9. 📱 Mobile/Desktop/Web Parity
- Consistent experience and feature set across all platforms.

### 10. 📊 Analytics & Reporting
- Visualize data with charts, graphs, and dashboards.
- Customizable reports and exports.

---

## 💡 How to Contribute or Suggest Features
- Open an issue or pull request on GitHub.
- Join discussions for feature planning and prioritization.

---

*This roadmap is updated regularly as features are implemented and new ideas are proposed!* 