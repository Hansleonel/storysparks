import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/**
 * Builds a styled narration prompt based on the story genre.
 * Following Gemini TTS prompting guide for expressive, emotional narration.
 */
function buildStyledPrompt(text: string, genre?: string): string {
  const styleMap: Record<string, string> = {
    // Spanish genres
    Romántico: `Deliver this love story with deep emotional intimacy. 
      Let your voice carry the warmth of tender moments, the flutter of hearts connecting.
      Speak softly during vulnerable confessions, let passion rise in moments of declaration.
      Pause meaningfully before emotional revelations. Let the listener feel the love.`,

    Aventura: `Narrate this adventure with infectious energy and wonder.
      Build suspense with lowered, tense tones before action moments.
      Let excitement burst through during discoveries and escapes.
      Vary your pace - slow and careful in dangerous moments, quick and breathless in chases.
      Make the listener's heart race with anticipation.`,

    Nostálgico: `Tell this story as if recalling a precious, bittersweet memory.
      Your voice should carry the weight of time passed, the ache of beautiful moments gone.
      Speak slowly, reflectively, with gentle pauses that let memories breathe.
      Let wistfulness color your words, as if each sentence is a photograph being examined.
      The listener should feel the tender melancholy of looking back.`,

    Felicidad: `Radiate pure joy and warmth in every word.
      Let genuine happiness shine through - the kind that makes others smile.
      Your voice should dance with lightness and celebration.
      Emphasize moments of laughter, connection, and simple pleasures.
      Make the listener feel uplifted, as if sunlight is warming their soul.`,

    Tristeza: `Deliver this with profound emotional depth and gentle sorrow.
      Let your voice carry the weight of loss, of longing, of beautiful sadness.
      Speak slowly, allowing each word to resonate with meaning.
      Pause at moments of pain, let silence speak where words cannot.
      The listener should feel moved, perhaps to tears, but also held in compassion.`,

    // English genres
    Romantic: `Deliver this love story with deep emotional intimacy.
      Let your voice carry the warmth of tender moments, the flutter of hearts connecting.
      Speak softly during vulnerable confessions, let passion rise in moments of declaration.
      Pause meaningfully before emotional revelations. Let the listener feel the love.`,

    Adventure: `Narrate this adventure with infectious energy and wonder.
      Build suspense with lowered, tense tones before action moments.
      Let excitement burst through during discoveries and escapes.
      Vary your pace - slow and careful in dangerous moments, quick and breathless in chases.
      Make the listener's heart race with anticipation.`,

    Nostalgic: `Tell this story as if recalling a precious, bittersweet memory.
      Your voice should carry the weight of time passed, the ache of beautiful moments gone.
      Speak slowly, reflectively, with gentle pauses that let memories breathe.
      Let wistfulness color your words, as if each sentence is a photograph being examined.
      The listener should feel the tender melancholy of looking back.`,

    Happiness: `Radiate pure joy and warmth in every word.
      Let genuine happiness shine through - the kind that makes others smile.
      Your voice should dance with lightness and celebration.
      Emphasize moments of laughter, connection, and simple pleasures.
      Make the listener feel uplifted, as if sunlight is warming their soul.`,

    Sadness: `Deliver this with profound emotional depth and gentle sorrow.
      Let your voice carry the weight of loss, of longing, of beautiful sadness.
      Speak slowly, allowing each word to resonate with meaning.
      Pause at moments of pain, let silence speak where words cannot.
      The listener should feel moved, perhaps to tears, but also held in compassion.`,
  };

  const style =
    styleMap[genre ?? ""] ||
    `Tell this story with genuine emotional connection.
    Let your voice carry the full range of human feeling.
    Pause meaningfully, vary your tone with the narrative's flow.
    Make the listener feel immersed in the story, as if living it themselves.`;

  return `# AUDIO PROFILE: Master Storyteller

## THE SCENE
You are narrating a deeply personal story filled with real emotions and memories.
This is not just text to read - these are someone's cherished moments, their dreams, their heart.
Every word matters. Every pause has meaning.

## DIRECTOR'S NOTES
${style}

## PERFORMANCE GUIDANCE
- Breathe naturally between sentences
- Allow emotional moments to land before continuing
- Let your voice reflect the emotional journey
- Speak as if sharing a secret with a close friend
- Make every word feel intentional and heartfelt

## THE STORY
${text}`;
}

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
    const { text, storyId, genre } = await req.json();

    if (!text || text.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Text is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(
      `[Gemini TTS] Generating audio for story ${storyId}, user: ${user.id}`
    );
    console.log(`[Gemini TTS] Text length: ${text.length} characters`);
    console.log(`[Gemini TTS] Genre: ${genre || "not specified"}`);

    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) {
      console.error("[Gemini TTS] GEMINI_API_KEY not configured");
      return new Response(
        JSON.stringify({ error: "TTS service not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Build styled prompt for narration
    const styledPrompt = buildStyledPrompt(text, genre);
    console.log("[Gemini TTS] Using styled prompt for narration");

    // Call Gemini TTS API with optimized settings
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=${geminiApiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: styledPrompt }] }],
          generationConfig: {
            responseModalities: ["AUDIO"],
            speechConfig: {
              voiceConfig: {
                prebuiltVoiceConfig: {
                  voiceName: "Algieba", // Smooth, warm masculine voice
                },
              },
            },
          },
        }),
      }
    );

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text();
      console.error("[Gemini TTS] API error:", errorText);
      return new Response(
        JSON.stringify({ error: "Failed to generate audio" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const result = await geminiResponse.json();

    // Extract audio data from response
    const audioData =
      result?.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;

    if (!audioData) {
      console.error("[Gemini TTS] No audio data in response:", result);
      return new Response(
        JSON.stringify({ error: "No audio data received" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(
      `[Gemini TTS] Audio generated successfully, base64 length: ${audioData.length}`
    );

    // Return with "base64:" prefix so Flutter knows how to handle it
    return new Response(
      JSON.stringify({
        success: true,
        audioData: `base64:${audioData}`,
        storyId: storyId,
        characterCount: text.length,
        provider: "gemini",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (e) {
    console.error("[Gemini TTS] Unexpected error:", e);
    return new Response(
      JSON.stringify({ error: `Unexpected error: ${e.message}` }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
