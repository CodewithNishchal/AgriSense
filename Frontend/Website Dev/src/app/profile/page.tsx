"use client"
import axios from "axios"
import Link from "next/link"
import toast from "react-hot-toast"
import { useRouter } from "next/navigation"
import React, { useState } from "react"

export default function ProfilePage() {

    const router = useRouter();
    const [data, setData] = useState("nothing");
    const logout = async () => {
        try {
            axios.get("/api/users/logout")
            toast.success("Logout successful")
            router.push("/login")
        } catch (error: any) {
            console.log("Logout error", error.message)
            toast.error("Logout error: " + error.message)
        }
    }

    const getUserDetails = async () => {
        try {
            const res = await axios.get("/api/users/me")
            console.log("User details", res.data)
            setData(res.data.data._id);
        } catch (error) {
            console.log("Get user details error", error);
        }
    }

    return (
        <div className="flex flex-col items-center justify-center min-h-screen py-2">
            <h1>This is profile page</h1>
            <h2>{data === 'nothing' ? "No data yet to show" : 
                <Link href={`/profile/${data}`}> {data} </Link> }</h2>
            <hr />

            <button
                className=""
                onClick={logout}>                
                Logout
            </button>
            <button
                className=""
                onClick={getUserDetails}>                
                Get User Details
            </button>
        </div>
    )
}