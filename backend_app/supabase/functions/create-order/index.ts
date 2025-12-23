import { serve } from "std/server"
import { createClient } from "supabase"




const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
}

serve(async (req:  Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseKey) throw new Error('Variables d’environnement manquantes');

    const supabaseClient = createClient(supabaseUrl, supabaseKey);

    const { game_id, user_id, total_price } = await req.json();
    if (!game_id || !user_id || !total_price) throw new Error('Données manquantes');

    const { data, error } = await supabaseClient
      .from('orders')
      .insert([{ game_id, user_id, total_price, status: 'pending' }])
      .select()
      .single();

    if (error) throw error;

    return new Response(JSON.stringify({ success: true, order: data }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
})
