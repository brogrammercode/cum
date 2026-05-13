# AI Execution Rules - Cum Project

All AI agents and coding assistants MUST follow these rules strictly before and during any task execution in this repository.

## 1. Pre-Execution Analysis
- **Deep UI Analysis**: Before modifying or creating any UI, deeply analyze the `context/mobile_ui_standard.md` file. Ensure that any proposed UI change aligns with the defined colors, typography, border radii, and spacing.
- **Pattern Matching**: Review existing files in the target directory to understand the local coding patterns, naming conventions, and architecture.

## 2. Architecture & Folder Structure
- **Feature-Based Structure**: Follow the established feature-based architecture in `apps/mobile/lib/features/`:
    - `pages/`: UI screens.
    - `components/`: Feature-specific components.
    - `cubit/` or `bloc/`: State management.
    - `repo/`: Data repositories.
    - `models/`: Data models.
- **Global Resources**:
    - `lib/components/ui/`: Global, reusable UI components (Buttons, Inputs, etc.).
    - `lib/core/`: Central themes, colors, routes, and DI.
    - `lib/constants/`: App-wide constants and asset paths.

## 3. UI Consistency & Reusability
- **Reusable Components First**: Always check `lib/components/ui/` for existing components before building a new UI element. If a component is missing, create it in a reusable manner.
- **No Hardcoded Styles**:
    - **Colors**: Use `AppColors` from `lib/core/color.dart`.
    - **Typography**: Use `Theme.of(context).textTheme` or styles from `lib/core/theme.dart`.
- **Responsive Design**: Use `ScreenUtil` (e.g., `.w`, `.h`, `.sp`, `.r`) for all dimensions, padding, margins, and font sizes to maintain consistency across different screen sizes.

## 4. Asset Management
- **Centralized Assets**: Never hardcode asset strings. Add all new asset paths to `AppAssets` in `lib/constants/assets.dart` and use the constant.

## 5. State Management & Logic
- **Cubit/Bloc**: Follow the established state management pattern (Cubit) found in the `features/` directory.
- **Separation of Concerns**: Keep business logic out of the UI files. Use repositories for data fetching and Cubits for state transitions.

## 6. Code Quality
- **100% Comment-Free Code**: Code must be 100% free of comments. Use self-documenting code with clear, descriptive variable and function names to explain logic.
- **Clean Diffing**: When modifying files, preserve the existing logic structure but ensure no comments remain in the modified areas.
- **Linting**: Adhere to the project's `.dartinspect` or default Flutter lint rules.

## 7. Execution Workflow
1.  **Read**: Analyze the requirements and relevant standard files.
2.  **Plan**: Draft an implementation plan that follows the above rules.
3.  **Execute**: Write modular, reusable, and themed code.
4.  **Verify**: Ensure the code builds and aligns visually with the standards.
