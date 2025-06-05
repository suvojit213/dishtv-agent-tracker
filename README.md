# Dishtv Agent Performance Tracker

**Author:** Suvojeet Sengupta (suvojit213)

A web application designed for DishTV customer care agents to track their daily login hours and call counts, view monthly performance summaries, and estimate their salary based on performance metrics.

[![Made with Love](https://img.shields.io/badge/Made%20with%20%E2%9D%A4%EF%B8%8F%20by-Suvojeet-blue)](https://github.com/suvojit213)

## Features

*   **Daily Tracking:** Easily log daily login hours (in HH:MM:SS format using dropdowns) and the number of calls handled.
*   **Monthly Dashboard:** Get a quick overview of the current month's performance:
    *   Total login hours and total calls.
    *   Average daily login hours and calls.
    *   Visual chart displaying daily login hours (bar) and call count (line) trends.
    *   Estimated salary calculation based on performance (₹4.30 per call + ₹2000 bonus for meeting targets: 750+ calls & 100+ hours).
*   **Detailed Monthly Reports:** View a comprehensive report for the selected month, including:
    *   Summary statistics (Total/Average hours and calls).
    *   Detailed salary breakdown (Base + Bonus).
    *   A table listing all daily entries for the month.
*   **All Reports Section:** Access and review performance reports for any previous month with recorded data.
*   **PDF Export:** Download professional-looking monthly reports as PDF files for record-keeping or sharing.
*   **Edit & Delete:** Modify or remove incorrect entries easily from the monthly report view.
*   **Local Storage:** All data is securely stored directly in your browser's local storage, ensuring privacy.
*   **Responsive Design:** Clean, modern, iOS-inspired user interface (dark theme) that works seamlessly on desktop and mobile devices.
*   **PWA Ready:** Can be installed on your device like a native app for quick access.

## Live Demo

You can try the live application here: [https://kagacyye.manus.space](https://kagacyye.manus.space)

## Tech Stack

*   **Frontend:** React, TypeScript
*   **Build Tool:** Vite
*   **Charting:** Chart.js
*   **PDF Generation:** jsPDF, jspdf-autotable
*   **Styling:** CSS (Custom styles inspired by iOS)
*   **Package Manager:** pnpm

## Getting Started

Follow these instructions to set up the project locally.

### Prerequisites

*   Node.js (v18 or later recommended)
*   pnpm (You can use npm or yarn as well, but this project uses pnpm)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd dishtv_tracker
    ```
3.  **Install dependencies:**
    ```bash
    pnpm install
    ```

### Running Locally

To start the development server:

```bash
pnpm dev
```

This will open the application in your default browser, usually at `http://localhost:5173`.

### Building for Production

To create an optimized production build:

```bash
pnpm build
```

The build artifacts will be stored in the `dist/` directory.

## Usage

1.  **Dashboard:** The main screen shows the current month's statistics, performance chart, salary estimate, and quick navigation buttons.
2.  **Add Entry:** Tap the floating `+` button to open the entry form. Select the date using the calendar, choose login hours, minutes, and seconds from the dropdowns, enter the call count, and tap "Save Entry".
3.  **Monthly Performance:** Click the "Monthly Performance" button on the dashboard or navigate via the bottom bar to see the detailed report for the currently selected month. Use the `<` and `>` arrows to change months.
4.  **All Entries:** Click the "All Entries" button on the dashboard or navigate via the bottom bar. Select a month from the dropdown to view its full report and download the PDF.
5.  **Edit/Delete:** In the "Monthly Performance" view, use the pencil icon to edit an entry or the trash icon to delete it.
6.  **PDF Download:** In the "All Reports" view, click the "Download PDF" button after selecting a month.
7.  **Install App:** On supported browsers (like Chrome on Android), look for an "Install" or "Add to Home Screen" option in the browser menu to install the app for easier access.

## Author

Made with ❤️ by **Suvojeet Sengupta**
*   GitHub: [suvojit213](https://github.com/suvojit213)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details. (Note: LICENSE file needs to be created)

