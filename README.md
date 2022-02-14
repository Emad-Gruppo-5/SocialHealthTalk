# SocialHealthTalk
Socials' advent and recent technological revolution have brought about human interaction weakening, especially in the last period with the Covid-19. The category of people most affected is that with disability or elderly people needs steady presence of a relative which they feel less alone and a doctor interests of their health state daily. In this sense, it would help an application does the ability to get close relatives as much as possibile to their kins and to keep tracking steady of the health state and the mood of people in need. 

After a careful market research, there is no app with these functionalities. For this reason, the goals of this app are: 
1. To check the health state of people interested through voice tone recognition to take action in case of need,
2. To give the opportunity to a doctor to schedule a series of activities which the patient must follow.
3. To keep under control the state of patients

## How to run
### Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install)
- [Python](https://www.python.org/downloads/)
  - [Flask](https://flask.palletsprojects.com/en/2.0.x/installation/)

### Client
`flutter run --no-sound-null-safety`

### Server
- app.py
  - `venv\Scripts\activate`
  - `flask run`
- http_scheduling/
  - `venv\Scripts\activate`
  - `py scheduling.py`
- scheduler_ai/
  - `venv\Scripts\activate`
  - `py scheduler_analisi.py`

## Demo app


https://user-images.githubusercontent.com/43890556/153902587-55d188e9-6868-4842-9164-6acb72f18a46.mp4

