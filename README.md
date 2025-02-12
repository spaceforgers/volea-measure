# Volea Measure
Volea Measure is an open-source app for recording and analyzing motion data using iOS and watchOS devices. It captures high-frequency sensor data during dynamic activities, organizes recording sessions and individual movements, and even provides 3D visualizations of the captured data.


## What It Does

- **Motion Data Recording:**  
  Captures detailed sensor data (acceleration, rotation, attitude, etc.) at 60Hz using Core Motion.

- **Session & Movement Management:**  
  Organizes recordings into sessions and individual movements with precise timestamps.

- **3D Visualization:**  
  Renders animated 3D models that follow the recorded motion paths using SceneKit.

- **Cross-Platform Integration:**  
  Offers both an iOS app for comprehensive session management and a watchOS app for real-time feedback.

- **HealthKit Integration:**  
  Starts a workout session to keep the app active during physical activity.


## How to Use

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/spaceforgers/voleameasure.git
   cd voleameasure
   ```

2. **Open the project in Xcode:**
   Open the project with Xcode 16 or later.

3. **Configure capabilities:**
   For both the iOS and watchOS app, enable HealthKit, iCloud and App Groups.

4. **Build and run:**
   Choose the target scheme (iOS or watchOS) and run the app on a compatible device or simulator.


## Minimum Requirements

- **Xcode:** Version 16 or later
- **Swift:** Version 6 or later  
- **iOS:** Version 18 or later  
- **watchOS:** Version 11 or later


## Contributing

Contributions are welcome! Since this is an open-source project, feel free to use, modify, and distribute it. To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes and push your branch.
4. Open a pull request to merge your changes into the main project.


## License

This project is licensed under the MIT License. You are free to use, modify, and share it as you see fit.

Happy measuring!
