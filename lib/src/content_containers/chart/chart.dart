// This is the main export file for the WebbUI Chart component.
// Consumers of the UI kit only need to import this single file.
library;

// Export the main widget class
export 'chart_widget.dart' show WebbUIChart;

// Export the data models and definitions used by the widget
export 'chart_definitions.dart';

// Note: The internal components (painter, legend) are not exported,
// keeping the public API clean.
