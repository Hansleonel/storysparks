import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  if (req.method !== "DELETE") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  // Obtén el JWT del usuario desde el header Authorization
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response("Unauthorized", { status: 401 });
  }
  const jwt = authHeader.replace("Bearer ", "");

  // Crea el cliente de Supabase con la Service Role Key
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Verifica el JWT y extrae el user_id
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser(jwt);

  if (userError || !user) {
    return new Response("Invalid user", { status: 401 });
  }

  try {
    console.log(`Starting deletion process for user: ${user.id}`);

    // 1. Primero, eliminar datos en tablas relacionadas
    // Si hay otras tablas que podrían causar problemas de foreign key, agregar aquí
    // Por ejemplo: subscriptions, user_preferences, etc.
    try {
      console.log("Calling cleanup_user_data stored procedure");
      const { error: otherTablesError } = await supabase.rpc('cleanup_user_data', {
        user_id_param: user.id
      });

      if (otherTablesError) {
        console.error('Error cleaning up related tables:', otherTablesError);
        return new Response(JSON.stringify({ error: `Error cleaning up related tables: ${otherTablesError.message}` }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        });
      }
      console.log("Successfully cleaned up related data");
    } catch (rpcError) {
      console.error('RPC Error:', rpcError);
      return new Response(JSON.stringify({ error: `Error in RPC call: ${rpcError.message || JSON.stringify(rpcError)}` }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 2. Eliminar perfil del usuario
    console.log("Deleting user profile");
    const { error: profileError } = await supabase
      .from('profiles')
      .delete()
      .eq('id', user.id);

    if (profileError) {
      console.error('Error deleting profile:', profileError);
      return new Response(JSON.stringify({ error: `Error deleting profile: ${profileError.message}` }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }
    console.log("Successfully deleted user profile");

    // 3. Finalmente eliminar el usuario de Auth
    console.log("Deleting user from auth system");
    const { error } = await supabase.auth.admin.deleteUser(user.id);

    if (error) {
      console.error('Error deleting auth user:', error);
      return new Response(JSON.stringify({ error: `Error deleting user: ${error.message}` }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    console.log(`Successfully deleted user: ${user.id}`);
    return new Response(JSON.stringify({ success: true }), { 
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (e) {
    console.error('Unexpected error during user deletion:', e);
    return new Response(JSON.stringify({ error: `Unexpected error: ${e.message || JSON.stringify(e)}` }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});