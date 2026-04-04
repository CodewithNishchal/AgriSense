import { verify } from "crypto";
import mongoose, { trusted } from "mongoose";

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: [true, "Username is required"],
        unique: true
    },
    email: { 
        type: String,
        required: [true, "Please provide an email address"],
        unique: true
    },
    password: {
        type: String,
        required: [true, "Please provide the password"]
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    isAdmin: {
        type: Boolean,
        default: false
    },
    phone_number: {
        type: String,
        default: ""
    },
    kyc_document_type: {
        type: String,
        default: "Aadhar"
    },
    kyc_number: {
        type: String,
        default: ""
    },
    base_pincode: {
        type: String,
        default: ""
    },
    service_radius_km: {
        type: Number,
        default: 10
    },
    total_fleet_size: {
        type: Number,
        default: 1
    },
    primary_equipment_type: {
        type: String,
        default: "Tractors"
    },
    upi_id: {
        type: String,
        default: ""
    },
    forgotPasswordToken: String,
    forgotPasswordTokenExpiry: Date,
    verifyToken: String,
    verifyTokenExpiry: Date
});

const User = mongoose.models.users || mongoose.model("users", userSchema);

export default User;