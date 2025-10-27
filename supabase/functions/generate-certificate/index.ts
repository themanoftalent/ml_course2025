import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface RequestPayload {
  user_id: string;
  course_id: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing authorization header');
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);

    if (userError || !user) {
      throw new Error('Unauthorized');
    }

    const { user_id, course_id }: RequestPayload = await req.json();

    if (!user_id || !course_id) {
      return new Response(
        JSON.stringify({ error: "user_id and course_id are required" }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    if (user.id !== user_id) {
      return new Response(
        JSON.stringify({ error: "Unauthorized to generate certificate for another user" }),
        {
          status: 403,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const { data: existingCert } = await supabaseClient
      .from('certificates')
      .select('id, certificate_id')
      .eq('user_id', user_id)
      .eq('course_id', course_id)
      .maybeSingle();

    if (existingCert) {
      return new Response(
        JSON.stringify({
          message: "Certificate already exists",
          certificate_id: existingCert.certificate_id,
        }),
        {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const { data: isComplete, error: completionError } = await supabaseClient
      .rpc('check_course_completion', {
        p_user_id: user_id,
        p_course_id: course_id,
      });

    if (completionError) {
      throw new Error('Failed to check course completion');
    }

    if (!isComplete) {
      return new Response(
        JSON.stringify({ error: "Course not completed yet" }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const randomString = crypto.randomUUID().split('-')[0].toUpperCase();
    const certificate_id = `SOFTAI-${randomString}`;

    const { data: certificate, error: insertError } = await supabaseClient
      .from('certificates')
      .insert({
        user_id,
        course_id,
        certificate_id,
        issue_date: new Date().toISOString(),
      })
      .select()
      .single();

    if (insertError || !certificate) {
      throw new Error('Failed to create certificate record');
    }

    return new Response(
      JSON.stringify({
        message: "Certificate generated successfully",
        certificate_id: certificate.certificate_id,
        certificate,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});