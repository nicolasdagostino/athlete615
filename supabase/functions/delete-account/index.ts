import { createClient } from 'npm:@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const token = authHeader.replace(/^Bearer\s+/i, '').trim()
    if (!token) {
      return new Response(JSON.stringify({ error: 'Missing bearer token' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const adminClient = createClient(supabaseUrl, serviceRoleKey)

    const {
      data: { user },
      error: userError,
    } = await adminClient.auth.getUser(token)

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: userError?.message ?? 'Unauthorized' }),
        {
          status: 401,
          headers: { 'Content-Type': 'application/json' },
        }
      )
    }

    const userId = user.id

    await adminClient.from('workout_likes').delete().eq('user_id', userId)
    await adminClient.from('workout_comments').delete().eq('user_id', userId)
    await adminClient.from('class_bookings').delete().eq('user_id', userId)

    const membershipsRes = await adminClient
      .from('member_memberships')
      .select('id')
      .eq('user_id', userId)

    const membershipIds = membershipsRes.data?.map((x) => x.id) ?? []

    if (membershipIds.length > 0) {
      await adminClient
        .from('membership_payments')
        .delete()
        .in('membership_id', membershipIds)
    }

    await adminClient.from('member_memberships').delete().eq('user_id', userId)
    await adminClient.from('gym_user_roles').delete().eq('user_id', userId)

    if (user.email) {
      await adminClient.from('gym_invites').delete().eq('email', user.email)
    }

    await adminClient.from('profiles').delete().eq('id', userId)

    const { error: deleteAuthError } = await adminClient.auth.admin.deleteUser(userId)

    if (deleteAuthError) {
      return new Response(JSON.stringify({ error: deleteAuthError.message }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
