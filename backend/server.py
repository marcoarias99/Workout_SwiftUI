from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
import uuid

load_dotenv()

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB connection
MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017/timer_app")
client = MongoClient(MONGO_URL)
db = client.timer_app

# Collections
routines_collection = db.routines
schedules_collection = db.schedules

# Pydantic models
class Exercise(BaseModel):
    id: str
    name: str
    duration: int  # in seconds
    sets: int
    rest_duration: int  # rest between sets in seconds

class Routine(BaseModel):
    id: str
    name: str
    exercises: List[Exercise]
    total_duration: int  # calculated total duration
    created_at: datetime

class DaySchedule(BaseModel):
    id: str
    day: str  # Monday, Tuesday, etc.
    routine_id: str
    routine_name: str
    exercises: List[str]  # exercise names for quick display

# Initialize with sample data
@app.on_event("startup")
async def startup_event():
    # Clear existing data
    routines_collection.delete_many({})
    schedules_collection.delete_many({})
    
    # Create sample exercises
    sample_exercises = [
        Exercise(
            id=str(uuid.uuid4()),
            name="Push Ups",
            duration=60,
            sets=3,
            rest_duration=30
        ),
        Exercise(
            id=str(uuid.uuid4()),
            name="Squats",
            duration=45,
            sets=3,
            rest_duration=30
        ),
        Exercise(
            id=str(uuid.uuid4()),
            name="Plank",
            duration=30,
            sets=3,
            rest_duration=15
        )
    ]
    
    # Create sample routine
    total_duration = sum(ex.duration * ex.sets + ex.rest_duration * (ex.sets - 1) for ex in sample_exercises)
    
    sample_routine = Routine(
        id=str(uuid.uuid4()),
        name="LEGS",
        exercises=sample_exercises,
        total_duration=total_duration,
        created_at=datetime.now()
    )
    
    # Insert routine
    routines_collection.insert_one(sample_routine.dict())
    
    # Create sample schedule for Friday and Wednesday
    sample_schedule_friday = DaySchedule(
        id=str(uuid.uuid4()),
        day="Friday",
        routine_id=sample_routine.id,
        routine_name=sample_routine.name,
        exercises=[ex.name for ex in sample_exercises]
    )
    
    sample_schedule_wednesday = DaySchedule(
        id=str(uuid.uuid4()),
        day="Wednesday",
        routine_id=sample_routine.id,
        routine_name=sample_routine.name,
        exercises=[ex.name for ex in sample_exercises]
    )
    
    schedules_collection.insert_one(sample_schedule_friday.dict())
    schedules_collection.insert_one(sample_schedule_wednesday.dict())

# API endpoints
@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}

@app.get("/api/today")
async def get_today_schedule():
    today = datetime.now()
    day_name = today.strftime("%A")
    
    # Get today's schedule
    schedule = schedules_collection.find_one({"day": day_name})
    
    if schedule:
        # Get the routine details
        routine = routines_collection.find_one({"id": schedule["routine_id"]})
        
        return {
            "date": today.strftime("%Y-%m-%d"),
            "day": day_name,
            "has_workout": True,
            "routine": {
                "id": routine["id"],
                "name": routine["name"],
                "exercises": routine["exercises"],
                "total_duration": routine["total_duration"]
            }
        }
    else:
        return {
            "date": today.strftime("%Y-%m-%d"),
            "day": day_name,
            "has_workout": False,
            "routine": None
        }

@app.get("/api/routines")
async def get_routines():
    routines = list(routines_collection.find({}, {"_id": 0}))
    return routines

@app.get("/api/routines/{routine_id}")
async def get_routine(routine_id: str):
    routine = routines_collection.find_one({"id": routine_id}, {"_id": 0})
    if not routine:
        raise HTTPException(status_code=404, detail="Routine not found")
    return routine

@app.post("/api/routines")
async def create_routine(routine: Routine):
    routine_dict = routine.dict()
    routines_collection.insert_one(routine_dict)
    return {"message": "Routine created successfully", "routine": routine_dict}

@app.get("/api/schedule")
async def get_weekly_schedule():
    schedules = list(schedules_collection.find({}, {"_id": 0}))
    return schedules

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)