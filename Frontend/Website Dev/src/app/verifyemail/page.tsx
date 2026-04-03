"use client"
import axios from "axios"
import { set } from "mongoose"
import Link from "next/link"
import { disconnect } from "process"
import { use, useEffect, useState } from "react"

export default function VerifyEmailPage() {
    const [token, setToken] = useState("")
    const [verified, setVerified] = useState(false)
    const [error, setError] = useState(false)

    const verifyUserEmail = async () => {
        try {
            await axios.post("/api/users/verifyemail", { token })
            setVerified(true)
        } catch (error: any) {
            setError(true)
            console.error("Error verifying email:", error.response?.data || error.message)
        }
    }

    useEffect(() => {
        const urlToken = window.location.search.split("=")[1];
        console.log(urlToken)
        setToken(urlToken || "")
    }, [])

    useEffect(() => {
        if(token.length > 0) {
            verifyUserEmail()
        }
    }, [token])

    return (
        <div className="flex flex-col items-center justify-center min-h-screen py-2">
            <h1 className="text-4xl">Verify Email</h1>
            <h2 className="p-2 bg-orange-500 text-black">
                {token ? `${token}`: "No token found in URL"}
            </h2>

            {verified && (
                <div >
                    <h2 className="text-2xl">Email verified successfully!</h2>
                    <Link href="/login">Go to Login</Link>
                </div>
            )}
            {error && (
                <div>
                    <h1 className="text-2xl bg-red-500 text-black">Error</h1>
                </div>
            )}
        </div>
    )
}