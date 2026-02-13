import { serve } from "std/server"
import { createClient } from "supabase"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    if (!supabaseUrl || !supabaseKey) throw new Error('Variables d\'environnement manquantes')

    const supabaseClient = createClient(supabaseUrl, supabaseKey)

    // Format envoyé par l'app Flutter
    const { client_id, category, total_price, pickup_data, delivery_data } = await req.json()

    if (!category || total_price == null) throw new Error('category et total_price requis')

    const { data, error } = await supabaseClient
      .from('orders')
      .insert([{
        client_id: client_id || null,
        category,
        total_price: Number(total_price),
        pickup_data: pickup_data || {},
        delivery_data: delivery_data || {},
        status: 'pending',
      }])
      .select()
      .single()

    if (error) throw error

    return new Response(JSON.stringify({ success: true, order: data }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    const message = error instanceof Error ? error.message : 'Erreur inconnue'
    return new Response(JSON.stringify({ error: message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
