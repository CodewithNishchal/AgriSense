export default async function UserProfile({ params }: any) {
    
    //You have to wait for the params to be available in NextJs now
    const finalParams = await params;

    return (
        <div className="flex flex-col items-center justify-center min-h-screen py-2">
            <p
                className="text-4xl"
            >This is your id : {finalParams?.id || "unknown"}</p>
            <hr />
            <h1>Thanks for comming</h1>
        </div>
    )
}