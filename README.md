# 🪺 DataNest — Unlimited Custom Data Platform

**DataNest** is a next-generation, no-code data platform that empowers you to create, manage, and sync your own custom data structures. With a beautiful, dynamic UI and robust offline/online sync, DataNest is perfect for professionals, teams, and hobbyists who want total control over their data.

---

## 🌟 Overview

DataNest is your personal, flexible database builder — think of it as a cross between Notion, Airtable, and a spreadsheet, but with **no limits** on the types of data you can model. You define your own categories (Sections), add any fields you want (from simple text to advanced computed fields), and manage unlimited records. All data is stored locally (offline-first) and synced to the cloud (Firestore) for backup and cross-device access.

### Why DataNest?
- **Ultimate Flexibility:** Model any data structure — from inventory, contacts, and tasks to scientific research, business assets, or personal collections.
- **No-Code Power:** Build complex forms, relationships, and logic without writing a single line of code.
- **Offline + Cloud:** Work anywhere, sync everywhere. Never lose your data.
- **For Everyone:** Perfect for individuals, teams, small businesses, and power users.
- **Open & Extensible:** Add new field types, logic, and integrations as your needs grow.

### Example Use Cases
- **Inventory Management:** Track products, suppliers, purchase dates, warranty, and more.
- **CRM/Contacts:** Custom contact fields, tags, notes, and relationships.
- **Project Management:** Tasks, deadlines, priorities, attachments, and team assignments.
- **Personal Collections:** Books, movies, recipes, hobbies, and more.
- **Research & Science:** Custom experiment logs, data points, computed results.
- **Business Assets:** Equipment, maintenance, locations, barcodes, and files.

---

## 🚀 Features (In Detail)

### 🧩 Data Modeling
- **Unlimited Sections:**
  - Create any number of categories (e.g., Inventory, Contacts, Projects, Labs)
  - Each section has a name, icon, color, and description
  - Reorder sections for custom navigation
- **Custom Fields:**
  - Add any field type to each section
  - **Supported Field Types:**
    - Text, Number, Date, Time, DateTime
    - Checkbox, Switch, Toggle
    - Dropdown, Multi-select, Radio
    - File, Image, Attachment (with file type/size rules)
    - Relation (link to other records/sections)
    - Computed/Formula fields (auto-calculate values)
    - Color, Rating, Password, JSON, Currency, Barcode, Location, Signature, Custom Code
  - **Field Options:**
    - Required, Unique, Default Value, Hint/Help Text
    - Allowed values/options (for dropdowns, multi-select, radio)
    - Validation rules (regex, min/max, file type/size, custom logic)
    - Conditional visibility (show/hide fields based on other data)
    - Drag & drop field reordering
    - Attachments: Restrict file types, max size, image preview
    - Relations: Link to any other section or record
    - Computed: Dynamic formulas, auto-updating fields

### 📝 Record Management
- **Dynamic Forms:**
  - Add/edit records with forms generated from your custom fields
  - Each field type gets the right input widget (date picker, dropdown, file picker, etc.)
  - Multi-select, radio, and checkbox fields for rich data entry
- **Validation:**
  - Enforce required, unique, and custom rules at entry
  - Real-time feedback for invalid or missing data
- **Beautiful Record Display:**
  - Records shown in modern cards with icons, field labels, and values
  - Field values formatted and color-coded by type
  - Quick delete/edit with confirmation dialogs
- **Bulk Actions:** (Planned)
  - Select and delete/export multiple records at once

### 🗂️ Navigation & UI/UX
- **Dynamic Drawer:**
  - Instantly reflects your sections for easy navigation
  - Tap a section to see its records and fields
- **Modern UI:**
  - Responsive, accessible, and beautiful (Material Design)
  - Dark Mode for eye comfort
  - Color & Icon Pickers for sections and fields
  - All notifications (success/error) appear at the bottom for a clean experience
- **Tabs in Section Detail:**
  - Switch between Records, Fields, and Settings for each section
- **Search & Filter:** (Planned)
  - Quickly find records by any field or value

### 🛠️ Data & Sync
- **Offline-First:**
  - All data is stored locally with Hive for instant access and reliability
- **Cloud Sync:**
  - Automatic sync with Firestore (with `synced` status tracking)
  - Works seamlessly across devices
- **Robust Sync Logic:**
  - On login, all user data is fetched from Firebase and always overwrites Hive, ensuring local data is always up-to-date.
  - The UI always reads from Hive, guaranteeing instant access and correct display even after hot restart.
  - Any new or edited data is saved to Hive with `synced: false` and is automatically uploaded to Firebase when online, then marked as `synced: true`.
  - Extensive debugPrint instrumentation throughout the codebase for easy debugging and tracing of all sync and data actions.
- **Conflict Handling:**
  - Last-write-wins for now (future: merge/resolve)
- **Export/Import:** (Planned)
  - Export sections/records as JSON or CSV

### 🔒 Security & Extensibility
- **Authentication:** (Planned)
  - Firebase Auth for secure access (email, Google, etc.)
- **Role-based Access:** (Planned)
  - Permissions for teams and shared sections
- **Extensible:**
  - Easily add new field types, logic, and integrations
  - Modular codebase for rapid feature development

---

## 🏗️ How It Works

- **Sections:** User-defined categories (e.g., "Assets", "Contacts")
- **Fields:** Customizable fields per section (e.g., Name, Date, Photo, Tags)
- **Records:** Data entries, validated and structured by your fields
- **Controllers:** GetX manages all state, navigation, and logic
- **Hive Boxes:** Store sections, fields, and records locally
- **Firebase Sync:** Keeps your data safe and available everywhere
- **Debugging:** Extensive debugPrint statements throughout the codebase make it easy to trace all user, sync, and data actions in the debug console.

---

## 🛠️ Tech Stack

- **Flutter** — Cross-platform UI
- **GetX** — State management, navigation, dependency injection
- **Hive** — Local, offline-first database
- **Firebase** — Cloud sync, authentication, backup
- **flutter_colorpicker, file_picker, image_picker** — Rich field types

---

## 📁 Project Structure

- `lib/models/` — Hive data models (Section, Field, Record)
- `lib/controllers/` — GetX controllers for all features
- `lib/views/` — All UI screens, dialogs, and widgets
- `lib/bindings/` — GetX bindings for dependency injection
- `lib/services/` — Data and sync logic

---

## ⚡ Quick Start

1. **Clone the repository**
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Generate Hive adapters:**
   ```sh
   flutter packages pub run build_runner build
   ```
4. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🧑‍💻 Usage

- **Create a Section:** Name, icon, color, description
- **Add Fields:** Choose type, set required/unique, add options
- **Add Records:** Fill out dynamic form, validated by your fields
- **Edit/Delete:** Manage sections, fields, and records with ease
- **Sync:** Data is saved locally and synced to Firestore automatically
- **Debug:** Use the debug console to trace all actions and sync events via debugPrint logs.

---

## 🔮 Future Enhancements / Roadmap

- **Templates:** Pre-built section/field templates for common use cases
- **Collaboration:** Shared sections and real-time multi-user editing
- **Advanced Conflict Resolution:** Merge, review, and resolve data conflicts
- **Version History:** Track changes and restore previous versions
- **AI Suggestions:** Smart field/section recommendations
- **Reminders & Notifications:** For time/date fields
- **Charts & Analytics:** Visualize numeric data
- **QR/Barcode Integration:** Scan and lookup records
- **Mobile Widgets:** Quick data entry from home screen
- **Custom Field Types:** User-defined widgets and logic
- **Role-based Access:** Permissions for teams
- **Export/Import:** JSON, CSV, and more
- **API Integrations:** Connect to external services
- **Mobile/Desktop/Web Parity:** Consistent experience everywhere

---

## 🤝 Contributing

Pull requests and suggestions are welcome! Please open an issue or submit a PR for improvements, bug fixes, or new features.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.