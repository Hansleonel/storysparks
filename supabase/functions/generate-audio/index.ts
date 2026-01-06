import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response("Method Not Allowed", {
      status: 405,
      headers: corsHeaders,
    });
  }

  // Verify authentication
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const jwt = authHeader.replace("Bearer ", "");
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Verify user
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser(jwt);
  if (userError || !user) {
    return new Response(JSON.stringify({ error: "Invalid user" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const { text, storyId, language } = await req.json();

    if (!text || text.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Text is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(`Generating audio for story ${storyId}, user: ${user.id}`);
    console.log(`Text length: ${text.length} characters`);
    console.log(`Language: ${language || "es (default)"}`);

    const replicateToken = Deno.env.get("REPLICATE_API_TOKEN");
    if (!replicateToken) {
      console.error("REPLICATE_API_TOKEN not configured");
      return new Response(
        JSON.stringify({ error: "TTS service not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Select voice_id based on language
    // English: R8_AZV3ZS7E, Spanish (default): R8_9MNYL3NX
    const voiceId = language === "en" ? "R8_AZV3ZS7E" : "R8_9MNYL3NX";
    console.log(`Using voice_id: ${voiceId} for language: ${language || "es"}`);

    // Call Replicate API - MiniMax Speech 2.6 Turbo
    const createResponse = await fetch(
      "https://api.replicate.com/v1/models/minimax/speech-2.6-turbo/predictions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${replicateToken}`,
          "Content-Type": "application/json",
          Prefer: "wait",
        },
        body: JSON.stringify({
          input: {
            text: text,
            voice_id: voiceId,
            speed: 0.9, // Slightly slower for more enjoyable narration
            emotion: "auto",
            audio_format: "mp3",
            channel: "stereo",
            sample_rate: 32000,
            bitrate: 128000,
          },
        }),
      }
    );

    if (!createResponse.ok) {
      const errorText = await createResponse.text();
      console.error("Replicate API error:", errorText);
      return new Response(
        JSON.stringify({ error: "Failed to generate audio" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const prediction = await createResponse.json();
    console.log(
      "Prediction created:",
      prediction.id,
      "Status:",
      prediction.status
    );

    // If prediction is not completed, poll for result
    let result = prediction;
    let attempts = 0;
    const maxAttempts = 60; // 60 * 2 seconds = 2 minutes max wait

    while (
      result.status !== "succeeded" &&
      result.status !== "failed" &&
      attempts < maxAttempts
    ) {
      await new Promise((resolve) => setTimeout(resolve, 2000));

      const pollResponse = await fetch(
        `https://api.replicate.com/v1/predictions/${prediction.id}`,
        {
          headers: {
            Authorization: `Bearer ${replicateToken}`,
          },
        }
      );

      result = await pollResponse.json();
      console.log("Poll attempt", attempts + 1, "Status:", result.status);
      attempts++;
    }

    if (result.status === "failed") {
      console.error("Prediction failed:", result.error);
      return new Response(
        JSON.stringify({ error: "Audio generation failed" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (result.status !== "succeeded") {
      console.error("Prediction timed out");
      return new Response(
        JSON.stringify({ error: "Audio generation timed out" }),
        {
          status: 504,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const audioUrl = result.output;
    console.log("Audio generated successfully:", audioUrl);

    return new Response(
      JSON.stringify({
        success: true,
        audioUrl: audioUrl,
        storyId: storyId,
        characterCount: text.length,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (e) {
    console.error("Unexpected error:", e);
    return new Response(
      JSON.stringify({ error: `Unexpected error: ${e.message}` }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
