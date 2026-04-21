# FocusNFlow

## Overview
FocusNFlow is a mobile study-planning application designed for college students. It helps users organize academic tasks, generate structured weekly study schedules, and collaborate with peers through real-time study group features.

The app uses a rule-based scheduling engine to prioritize tasks based on deadline urgency, estimated effort, and course weight. The generated study plan is transparent, editable, and designed to help students make better academic decisions.

## Core Features
- Task creation, editing, and deletion
- Rule-based weekly study plan generation
- Conflict detection and schedule adjustment suggestions
- Study group creation and collaboration
- Real-time group chat and shared study sessions
- Study room availability tracking
- Push notifications for reminders and updates

## Study-Planning Logic
The study-planning engine ranks tasks using three core factors:
- Deadline urgency
- Estimated effort
- Course weight

Tasks are assigned a priority score and then scheduled into available weekly time slots. If conflicts or overloaded periods are detected, the system generates adjustment suggestions. Users can edit recommendations to maintain control over their schedules.

## Tech Stack
- Frontend: Flutter (Dart)
- Backend / Database: Firebase Firestore
- Authentication: Firebase Authentication
- File Storage: Firebase Storage
- Notifications: Firebase Cloud Messaging (FCM)

## Firebase Services Used
- Firebase Authentication for user sign-in and session management
- Cloud Firestore for task data, schedules, groups, chat, and room availability
- Firebase Storage for optional uploaded study resources
- Firebase Cloud Messaging for reminders and study session notifications

## Team Members
- Trajuan Smith — Backend / Firebase Lead
- Raiyan Haque — Frontend / UI Lead

## Project Status
This project is currently in development for Mobile App Development Project 2.

## Repository Purpose
This repository contains the source code, documentation, and development progress for FocusNFlow.