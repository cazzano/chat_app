import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  try {
    const { username, password, 'secret-key': secretKey } = await request.json();

    if (!username || !password || !secretKey) {
      return NextResponse.json({ message: 'Missing required fields' }, { status: 400 });
    }

    const apiResponse = await fetch('https://chatapp-production-4eb5.up.railway.app/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'username': username,
        'password': password,
        'secret-key': secretKey,
      },
    });

    // It's important to check if the response has content before trying to parse it as JSON
    const contentType = apiResponse.headers.get("content-type");
    if (contentType && contentType.indexOf("application/json") !== -1) {
        const responseData = await apiResponse.json();
        return NextResponse.json(responseData, { status: apiResponse.status });
    } else {
        // If the response is not JSON, handle it as text or an empty response
        const textData = await apiResponse.text();
        return new NextResponse(textData, { status: apiResponse.status, headers: { 'Content-Type': 'text/plain' } });
    }

  } catch (error: any) {
    console.error('API Route Error:', error);
    return NextResponse.json({ message: 'Internal Server Error', error: error.message }, { status: 500 });
  }
}
