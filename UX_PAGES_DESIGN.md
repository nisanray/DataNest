# 🖥️ DataNest UX & Pages Design (Detailed, GetX Version)

A comprehensive guide to the advanced, consistent user experience for DataNest, now leveraging GetX for state management, navigation, and modularity. Includes detailed page layouts, placements, organizational structure, and specific design values for a modern, delightful, and accessible UI/UX.

---

## ⚡️ GetX Integration Notes
- **State Management:** Use GetX Controllers for each major feature (Sections, Fields, Records, Auth, etc.).
- **Navigation:** Use GetX routing (`Get.to()`, `Get.offAll()`, etc.) for all page transitions.
- **Reactivity:** Use `Obx` and other GetX reactive widgets to update UI in real time.
- **Dependency Injection:** Use GetX Bindings to inject controllers and services per page/module.
- **Modularity:** Organize code into modules (controllers/, bindings/, views/, etc.) for maintainability.

---

## 🎨 Global Design System

### Color Palette
- **Primary:** #4285F4 (Blue)
- **Secondary:** #34A853 (Green)
- **Accent:** #F9AB00 (Yellow)
- **Danger:** #EA4335 (Red)
- **Background:** #F5F7FA (Light), #181A20 (Dark)
- **Surface:** #FFFFFF (Light), #23262F (Dark)
- **Text Primary:** #181A20 (Light), #F5F7FA (Dark)
- **Text Secondary:** #5F6368 (Light), #B0B3B8 (Dark)
- **Divider:** #E0E0E0 (Light), #33343A (Dark)

### Spacing & Sizing
- **Base unit:** 8px
- **Padding:** 16px (standard), 24px (page edge)
- **Card radius:** 12px
- **Button height:** 48px
- **Icon size:** 24px (standard), 32px (drawer)

### Typography
- **Font family:** Inter, Roboto, or system sans-serif
- **Heading 1:** 28px, 700
- **Heading 2:** 22px, 600
- **Heading 3:** 18px, 600
- **Body:** 16px, 400
- **Caption:** 13px, 400

### Shadows & Elevation
- **Card:** 0 2px 8px rgba(60,60,60,0.08)
- **Drawer:** 0 4px 16px rgba(60,60,60,0.10)

### Other
- **Border radius:** 12px (cards, buttons, fields)
- **Focus ring:** 2px solid #4285F4
- **Transition:** 0.2s ease for hover/focus/active

---

## 1. Onboarding & Authentication
- **Layout:**
  - Centered card (max-width: 400px) on a soft gradient background
  - App logo at top, followed by welcome carousel (full width of card)
  - Auth fields below carousel, with social login buttons
  - Progress indicator at bottom
- **Placements:**
  - Logo: Top center
  - Carousel: Below logo, full card width
  - Auth fields: Stacked vertically, 16px gap
  - Social buttons: Horizontal, below fields
  - Progress: Bottom of card
- **Colors:**
  - Card: #FFFFFF (light), #23262F (dark)
  - Button: Primary/Secondary
  - Progress: Primary
- **Advanced UX:**
  - Animated transitions between steps (use GetX navigation for smooth page transitions)
  - Contextual tooltips for first-time users
  - AuthController manages state and validation

---

## 2. Home / Dashboard
- **Layout:**
  - **Header:** Fixed at top, 64px height, contains app name/logo, search bar, profile/avatar (right)
  - **Drawer/Sidebar:** Left, 72px wide (collapsed), 240px (expanded), contains navigation (Home, Sections, Settings)
  - **Main Content:** Responsive grid or list, with quick stats at top
- **Placements:**
  - Drawer: Left edge, always visible on desktop/tablet, overlays on mobile
  - Search: Top center in header
  - Quick stats: Top of main content, cards with icons
  - Add Section: Floating action button (FAB) bottom right
- **Colors:**
  - Drawer: Surface color, selected item uses Primary
  - Header: Surface, subtle shadow
  - FAB: Primary
- **Advanced UX:**
  - Drawer auto-collapses on small screens
  - Drag & drop section reordering (SectionController with reactive list)
  - Responsive breakpoints: mobile (<600px), tablet (600-1024px), desktop (>1024px)
  - Use GetX navigation for all page changes

---

## 3. Section List & Detail
- **Layout:**
  - **Section List:** Grid or list of cards, each card 280px wide, 16px gap
  - **Section Detail:** Header with section icon, name, color; tabs for Records, Fields, Settings
- **Placements:**
  - Edit/Delete: Icon buttons top right of card/detail header
  - Color picker: In section settings
  - Tabs: Below section header
- **Colors:**
  - Card: Surface, border uses Divider
  - Section color: Used as accent on header, icon background
- **Advanced UX:**
  - Swipe actions (mobile) for edit/delete
  - Animated transitions between list/detail (GetX navigation)
  - SectionController manages section state

---

## 4. Field Management
- **Layout:**
  - List of fields as cards or rows, each with type icon, name, and actions
  - Add/Edit Field: Modal dialog, full width on mobile
  - Drag handle for reordering
- **Placements:**
  - Add Field: FAB bottom right
  - Edit/Delete: Icon buttons right side of each field row
  - Live preview: Right side (desktop), below (mobile)
- **Colors:**
  - Field type icon: Primary/Secondary
  - Modal: Surface
- **Advanced UX:**
  - Live preview updates as fields are edited (FieldController with Obx)
  - Validation builder: Chips, toggles, dropdowns for rules
  - Conditional logic builder: Visual rule editor
  - Use GetX for field state and validation

---

## 5. Record List & Detail
- **Layout:**
  - **Record List:** Table (desktop) or card list (mobile), sortable columns
  - **Record Detail:** Drawer or modal with all field values, attachments gallery
- **Placements:**
  - Add Record: FAB bottom right
  - Search/Filter: Top of list
  - Bulk actions: Checkbox selection, toolbar appears on select
  - Unsynced indicator: Icon (e.g., cloud-off) on unsynced records
- **Colors:**
  - Unsynced: Accent or Danger (e.g., yellow or red icon)
  - Table header: Surface, bold text
- **Advanced UX:**
  - Infinite scroll or pagination (RecordController with reactive list)
  - Bulk delete/export
  - Highlight row on hover
  - Use GetX navigation for record detail

---

## 6. Dynamic Record Form
- **Layout:**
  - Form fields stacked vertically, grouped by type/section if many
  - Section headers for field groups
  - Save/Cancel fixed at bottom (sticky footer)
- **Placements:**
  - Required fields: Marked with * and colored label
  - Computed fields: Read-only, styled with subtle background
  - File/image upload: Inline with preview thumbnail
- **Colors:**
  - Required: Danger for asterisk
  - Field background: Surface
  - Focused field: Focus ring
- **Advanced UX:**
  - Conditional visibility: Fields animate in/out (reactive with Obx)
  - Auto-save drafts (snackbar confirmation)
  - File/image drag & drop
  - Use GetX for form state and validation

---

## 7. Attachments & Media Viewer
- **Layout:**
  - Gallery grid (3-4 columns desktop, 2 mobile)
  - Modal/lightbox for preview
- **Placements:**
  - Upload: Button top right of gallery
  - Download/Share: Icon buttons in preview modal
- **Colors:**
  - Gallery background: Surface
  - Selected: Primary border
- **Advanced UX:**
  - Multi-file upload with progress bar (reactive with Obx)
  - In-app image cropping/annotation tools
  - Use GetX for managing attachment state

---

## 8. Settings & Profile
- **Layout:**
  - Two-column (desktop): Nav list left, content right
  - Single column (mobile)
  - Profile card at top, settings sections below
- **Placements:**
  - Theme toggle: Top right of settings
  - Sync status: Banner at top or in profile card
  - Export/Import: Buttons in data section
- **Colors:**
  - Theme toggle: Accent
  - Sync status: Accent or Danger
- **Advanced UX:**
  - Animated theme switching (reactive with Obx)
  - Sync status: Progress bar, last sync time
  - In-app feedback: Floating button
  - Use GetX for settings/profile state

---

## 9. Error Handling & Notifications
- **Layout:**
  - Snackbars: Bottom center (mobile), bottom left (desktop)
  - Dialogs: Centered modal
  - Notification center: Drawer from right
- **Placements:**
  - Undo: Button in snackbar
  - Help: Icon in dialog headers
- **Colors:**
  - Error: Danger background, white text
  - Success: Secondary background, white text
- **Advanced UX:**
  - Undo for destructive actions
  - Contextual help popovers (question mark icons)
  - Use GetX for notification state

---

## 10. Accessibility & Responsiveness
- **Layout:**
  - All interactive elements minimum 48x48px
  - Keyboard focus outlines
  - Responsive breakpoints for all layouts
- **Placements:**
  - Font size controls: In settings
  - High-contrast toggle: In settings
- **Colors:**
  - High-contrast: #000000/#FFFFFF backgrounds, #4285F4 accents
- **Advanced UX:**
  - ARIA labels for all controls
  - Screen reader-friendly navigation order

---

**Tip:** Use GetX Controllers, Bindings, and reactive widgets for all state and navigation. Consistency and modularity are key for a delightful, professional experience. 