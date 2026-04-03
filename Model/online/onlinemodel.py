# pyright: reportMissingImports=false, reportMissingModuleSource=false
from google.colab import files
uploaded = files.upload()

from google.colab import files
uploaded = files.upload()

import torch
from torchvision import models
import torch.nn as nn

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = models.mobilenet_v2(weights=None)

model.classifier[1] = nn.Sequential(
    nn.Dropout(0.2),
    nn.Linear(model.last_channel, 38)
)

model.load_state_dict(torch.load("mobilenetv2_plant.pth", map_location=device))

model.to(device)
model.eval()

from torchvision import transforms
from PIL import Image

transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485,0.456,0.406],
                         [0.229,0.224,0.225])
])

image = Image.open("leaf.JPG").convert("RGB")

input_tensor = transform(image).unsqueeze(0).to(device)

with torch.no_grad():
    output = model(input_tensor)
    probs = torch.softmax(output, dim=1)[0]
    pred_idx = torch.argmax(probs).item()

print("Predicted class index:", pred_idx)
print("Confidence:", float(probs[pred_idx]))

from google.colab import files
uploaded = files.upload()

from google.colab import files
uploaded = files.upload()

import json, os, datetime, io, requests
import torch
import ipywidgets as widgets
from IPython.display import display, clear_output, HTML
from PIL import Image

PROTOCOLS_PATH = "disease_protocols.json"
CROP_AREA_ACRES = 2.0
MARKET_PRICE_RS = 1500.0
TOP_K = 3

LATITUDE = None
LONGITUDE = None

SUPABASE_URL = ""
SUPABASE_KEY = ""

OPENWEATHER_KEY = ""

CLASS_NAMES = [
    "Apple___Apple_scab", "Apple___Black_rot", "Apple___Cedar_apple_rust",
    "Apple___healthy", "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew", "Cherry_(including_sour)___healthy",
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot", "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight", "Corn_(maize)___healthy",
    "Grape___Black_rot", "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)", "Grape___healthy",
    "Orange___Haunglongbing_(Citrus_greening)", "Peach___Bacterial_spot",
    "Peach___healthy", "Pepper,_bell___Bacterial_spot", "Pepper,_bell___healthy",
    "Potato___Early_blight", "Potato___Late_blight", "Potato___healthy",
    "Raspberry___healthy", "Soybean___healthy", "Squash___Powdery_mildew",
    "Strawberry___Leaf_scorch", "Strawberry___healthy", "Tomato___Bacterial_spot",
    "Tomato___Early_blight", "Tomato___Late_blight", "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot", "Tomato___Spider_mites Two-spotted_spider_mite",
    "Tomato___Target_Spot", "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus", "Tomato___healthy",
]

_FUNGAL = {"blight","mold","scab","mildew","rot","spot","rust","esca","measles","scorch"}
_BACTERIAL = {"bacterial"}
_VIRAL = {"virus","viral","curl","mosaic","greening","haunglongbing"}
_PEST = {"mite","spider"}
_BIO_WEIGHT = {"viral":1.25, "bacterial":1.10, "fungal":1.00, "pest":0.90,
               "healthy":0.0, "unknown":0.85}

def detect_context(disease_key):
    k = disease_key.lower()
    if "healthy" in k:
        return {"is_healthy": True, "disease_type": "healthy", "bio_weight": 0.0}
    if any(x in k for x in _VIRAL):
        return {"is_healthy": False, "disease_type": "viral", "bio_weight": 1.25}
    if any(x in k for x in _BACTERIAL):
        return {"is_healthy": False, "disease_type": "bacterial", "bio_weight": 1.10}
    if any(x in k for x in _PEST):
        return {"is_healthy": False, "disease_type": "pest", "bio_weight": 0.90}
    if any(x in k for x in _FUNGAL):
        return {"is_healthy": False, "disease_type": "fungal", "bio_weight": 1.00}
    return {"is_healthy": False, "disease_type": "unknown", "bio_weight": 0.85}

def derive_severity(is_healthy, bio_weight, confidence):
    if is_healthy:
        return "✅ NONE", "NONE"
    eff = confidence * bio_weight
    if eff >= 0.85:
        return "🔴 HIGH — Significant risk. Immediate intervention required.", "HIGH"
    elif eff >= 0.55:
        return "🟡 MEDIUM — Moderate risk. Treat within 48 hours and monitor daily.", "MEDIUM"
    else:
        return "🟢 LOW — Early-stage detection. Preventive treatment advised.", "LOW"

def validate_result(result, context):
    is_healthy = context["is_healthy"]
    bio_weight = context["bio_weight"]
    confidence = context["confidence_raw"]

    sev_str, sev_level = derive_severity(is_healthy, bio_weight, confidence)
    result["severity"] = sev_str
    result["severity_level"] = sev_level

    if is_healthy:
        result["first_aid"] = "✅ No treatment required. Your plant is healthy. Continue regular monitoring and maintain good agronomic practices."
        prev_kw = {"monitor","inspect","preventive","prevent","continue","maintain","prune","mulch","rotation","certified","irrigation"}
        cleaned = [s for s in result.get("action_plan", []) if any(kw in s.lower() for kw in prev_kw)]
        if not cleaned:
            cleaned = [
                "Continue weekly field monitoring for early disease detection",
                "Apply preventive neem-based spray before monsoon season",
                "Maintain proper plant spacing and drainage for air circulation",
                "Use balanced NPK fertilizer to maintain plant immunity",
            ]
        result["action_plan"] = cleaned
        result["marketplace"]["product_type"] = "Preventive"
        result["marketplace"]["note"] = "No immediate purchase required. Optional preventive measures only."

    return result

def get_weather_advice(disease_key, lat, lon, api_key):
    k = disease_key.lower()
    if "healthy" in k:
        return "☀️ Plant is healthy. Continue monitoring."
    return "🌤️ Apply treatments in calm, dry conditions."

def insert_to_db(result):
    return None

def run_pipeline(send_to_db=False):
    clear_output(wait=True)
    display(header_html)

    with open(PROTOCOLS_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    protocols = data["protocols"]

    with torch.no_grad():
        output = model(input_tensor)
        probs = torch.softmax(output, dim=1)[0]

    k = min(TOP_K, len(CLASS_NAMES))
    topk_probs, topk_indices = torch.topk(probs, k)

    pred_idx = topk_indices[0].item()
    confidence = float(topk_probs[0].item())
    disease_key = CLASS_NAMES[pred_idx]

    context = detect_context(disease_key)
    context["confidence_raw"] = confidence

    protocol = protocols.get(disease_key)
    if not protocol:
        print("Unknown disease key")
        return

    result = {
        "disease": protocol["display_name"],
        "disease_key": disease_key,
        "confidence": round(confidence * 100, 2),
        "confidence_raw": round(confidence, 6),
        "first_aid": protocol["first_aid"],
        "action_plan": list(protocol["action_plan"]),
        "marketplace": protocol["marketplace"],
    }

    result = validate_result(result, context)
    print(result)

header_html = HTML("<h2>Crop Disease Intelligence Pipeline</h2>")

cb_db = widgets.Checkbox(value=False, description="Send to DB")
btn_run = widgets.Button(description="Run Analysis")

output_area = widgets.Output()

def on_run(b):
    with output_area:
        run_pipeline(send_to_db=cb_db.value)

btn_run.on_click(on_run)

display(header_html)
display(cb_db)
display(btn_run)
display(output_area)

with output_area:
    run_pipeline(send_to_db=False)