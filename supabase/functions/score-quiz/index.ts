import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface RequestPayload {
  quiz_id: string;
  user_answers: Record<string, number>;
}

interface QuestionResult {
  question_id: string;
  correct: boolean;
  explanation: string;
  points_earned: number;
  correct_index: number;
  user_answer: number;
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

    const { quiz_id, user_answers }: RequestPayload = await req.json();

    if (!quiz_id || !user_answers) {
      return new Response(
        JSON.stringify({ error: "quiz_id and user_answers are required" }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const { data: quiz, error: quizError } = await supabaseClient
      .from('quizzes')
      .select('id, pass_score_percent')
      .eq('id', quiz_id)
      .single();

    if (quizError || !quiz) {
      return new Response(
        JSON.stringify({ error: "Quiz not found" }),
        {
          status: 404,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const { data: questions, error: questionsError } = await supabaseClient
      .from('questions')
      .select('id, correct_index, explanation, points')
      .eq('quiz_id', quiz_id)
      .order('order');

    if (questionsError || !questions) {
      return new Response(
        JSON.stringify({ error: "Failed to fetch questions" }),
        {
          status: 500,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    let total_points = 0;
    let earned_points = 0;
    const per_question_results: QuestionResult[] = [];

    questions.forEach((question, index) => {
      total_points += question.points;
      const user_answer = user_answers[index.toString()];
      const is_correct = user_answer === question.correct_index;
      
      if (is_correct) {
        earned_points += question.points;
      }

      per_question_results.push({
        question_id: question.id,
        correct: is_correct,
        explanation: question.explanation,
        points_earned: is_correct ? question.points : 0,
        correct_index: question.correct_index,
        user_answer: user_answer ?? -1,
      });
    });

    const score_percent = total_points > 0 ? Math.round((earned_points / total_points) * 100) : 0;
    const passed = score_percent >= quiz.pass_score_percent;

    return new Response(
      JSON.stringify({
        score_percent,
        passed,
        per_question_results,
        total_points,
        earned_points,
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