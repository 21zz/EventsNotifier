import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

enum DarkMode { darkMode }

enum NotifyBefore {
  minutes15Before,
  minutes30Before,
  minutes45Before,
  hour1Before,
  hour2Before,
  hour4Before,
  hour8Before,
  hour12Before,
  day1Before,
  day2Before,
  day3Before,
  week1Before
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: ListView(padding: const EdgeInsets.all(15), children: [
                buildDarkMode(),
                SettingsGroup(
                    title: "General", children: <Widget>[buildNotifySettings()])
      ])));

  Widget buildDarkMode() => SwitchSettingsTile(
      title: "Dark Mode",
      leading: const Icon(Icons.dark_mode),
      settingKey: DarkMode.darkMode.name,
      defaultValue: false);

  Widget buildNotifySettings() => SimpleSettingsTile(
      title: "Notifications",
      subtitle: 'Notify before events',
      leading: const Icon(
        Icons.notifications,
      ),
      child: SettingsScreen(title: "Notification Settings", children: <Widget>[
        SettingsGroup(title: "Minutes", children: <Widget>[
          build15MinutesBefore(),
          build30MinutesBefore(),
          build45MinutesBefore(),
        ]),
        SettingsGroup(title: "Hours", children: <Widget>[
          build1HourBefore(),
          build2HoursBefore(),
          build4HoursBefore(),
          build8HoursBefore(),
          build12HoursBefore(),
        ]),
        SettingsGroup(title: "Days", children: <Widget>[
          build1DayBefore(),
          build2DaysBefore(),
          build3DaysBefore(),
        ]),
        SettingsGroup(title: "Weeks", children: <Widget>[build1WeekBefore()])
      ]));

  Widget build15MinutesBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.minutes15Before.name,
      title: "15 minutes before",
      defaultValue: false);

  Widget build30MinutesBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.minutes30Before.name,
      title: "30 minutes before",
      defaultValue: false);

  Widget build45MinutesBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.minutes45Before.name,
      title: "45 minutes before",
      defaultValue: false);

  Widget build1HourBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.hour1Before.name,
      title: "1 hour before",
      defaultValue: false);

  Widget build2HoursBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.hour2Before.name,
      title: "2 hours before",
      defaultValue: false);

  Widget build4HoursBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.hour4Before.name,
      title: "4 hours before",
      defaultValue: false);

  Widget build8HoursBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.hour8Before.name,
      title: "8 hours before",
      defaultValue: false);

  Widget build12HoursBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.hour12Before.name,
      title: "12 hours before",
      defaultValue: false);

  Widget build1DayBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.day1Before.name,
      title: "1 day before",
      defaultValue: false);

  Widget build2DaysBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.day2Before.name,
      title: "2 days before",
      defaultValue: false);

  Widget build3DaysBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.day3Before.name,
      title: "3 days before",
      defaultValue: false);

  Widget build1WeekBefore() => SwitchSettingsTile(
      settingKey: NotifyBefore.week1Before.name,
      title: "1 week before",
      defaultValue: false);
}
