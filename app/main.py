from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import re
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Color Classifier API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # ตอนทำพอร์ตใช้ * ไปก่อน
    allow_credentials=True,
    allow_methods=["*"],          # ให้ OPTIONS ผ่าน
    allow_headers=["*"],
)



HEX_RE = re.compile(r"^#?[0-9a-fA-F]{6}$")


class PredictRequest(BaseModel):
    hex: str = Field(..., examples=["#ff3366", "00ffcc"])


class PredictResponse(BaseModel):
    hex: str
    rgb: dict
    color_name: str
    group: str


def hex_to_rgb(hex_str: str) -> tuple[int, int, int]:
    h = hex_str.lstrip("#")
    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)
    return r, g, b


def classify_color(r: int, g: int, b: int) -> tuple[str, str]:
    # Very lightweight "inference": rule-based classification
    # You can replace this later with a real model without changing infra.

    # Brightness / grayscale checks
    max_c = max(r, g, b)
    min_c = min(r, g, b)
    brightness = (r + g + b) / 3
    saturation_like = max_c - min_c  # quick proxy

    if saturation_like < 18:
        if brightness < 60:
            return "black", "neutral"
        if brightness > 210:
            return "white", "neutral"
        return "gray", "neutral"

    # Dominant channel classification
    # Basic names + warm/cool grouping
    if r > g and r > b:
        if g > b:
            return "orange/red", "warm"
        return "red/magenta", "warm"
    if g > r and g > b:
        if b > r:
            return "teal/green", "cool"
        return "green", "cool"
    # b dominant
    if r > g:
        return "purple/blue", "cool"
    return "blue", "cool"


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(req: PredictRequest):
    value = req.hex.strip()
    if not HEX_RE.match(value):
        raise HTTPException(status_code=400, detail="hex must be 6-digit HEX like #ff3366")

    if not value.startswith("#"):
        value = f"#{value}"

    r, g, b = hex_to_rgb(value)
    color_name, group = classify_color(r, g, b)

    return {
        "hex": value.lower(),
        "rgb": {"r": r, "g": g, "b": b},
        "color_name": color_name,
        "group": group,
    }
