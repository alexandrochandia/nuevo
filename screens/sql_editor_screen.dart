import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/supabase_service.dart';

class SQLEditorScreen extends StatefulWidget {
  const SQLEditorScreen({super.key});

  @override
  State<SQLEditorScreen> createState() => _SQLEditorScreenState();
}

class _SQLEditorScreenState extends State<SQLEditorScreen> {
  final TextEditingController _sqlController = TextEditingController();
  final ScrollController _resultScrollController = ScrollController();

  List<Map<String, dynamic>> _queryResults = [];
  String _errorMessage = '';
  bool _isLoading = false;
  bool _showResults = false;

  // Predefined queries for quick access
  final List<Map<String, String>> _predefinedQueries = [
    {
      'name': 'Ver todas las tablas',
      'query': '''SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;'''
    },
    {
      'name': 'Usuarios registrados',
      'query': '''SELECT id, email, created_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 10;'''
    },
    {
      'name': 'Posts espirituales recientes',
      'query': '''SELECT id, title, content, created_at 
FROM spiritual_posts 
ORDER BY created_at DESC 
LIMIT 10;'''
    },
    {
      'name': 'Perfiles de usuario',
      'query': '''SELECT id, full_name, bio, location 
FROM user_profiles 
ORDER BY created_at DESC 
LIMIT 10;'''
    },
    {
      'name': 'Live streams activos',
      'query': '''SELECT id, title, description, is_active 
FROM live_streams 
WHERE is_active = true 
ORDER BY created_at DESC;'''
    },
    {
      'name': 'Estadísticas de matches',
      'query': '''SELECT 
  COUNT(*) as total_matches,
  AVG(compatibility_score) as avg_compatibility,
  COUNT(CASE WHEN conversation_started THEN 1 END) as conversations_started
FROM dating_matches 
WHERE is_active = true;'''
    },
    {
      'name': 'Grupos de estudio',
      'query': '''SELECT sg.id, sg.name, sg.description, 
  COUNT(sgm.user_id) as member_count
FROM study_groups sg
LEFT JOIN study_group_members sgm ON sg.id = sgm.group_id
GROUP BY sg.id, sg.name, sg.description
ORDER BY member_count DESC;'''
    },
    {
      'name': 'Chat rooms más activos',
      'query': '''SELECT cr.id, cr.name, 
  COUNT(cm.id) as message_count
FROM chat_rooms cr
LEFT JOIN chat_messages cm ON cr.id = cm.chat_room_id
GROUP BY cr.id, cr.name
ORDER BY message_count DESC
LIMIT 10;'''
    }
  ];

  @override
  void initState() {
    super.initState();
    _sqlController.text = _predefinedQueries.first['query']!;
  }

  Future<void> _executeQuery() async {
    if (_sqlController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _queryResults.clear();
      _showResults = false;
    });

    try {
      final response = await SupabaseService.supabase
          .rpc('execute_sql', params: {'query': _sqlController.text.trim()});

      if (response is List) {
        setState(() {
          _queryResults = List<Map<String, dynamic>>.from(response);
          _showResults = true;
        });
      } else {
        setState(() {
          _queryResults = [{'result': response.toString()}];
          _showResults = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkMissingTables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _queryResults.clear();
      _showResults = false;
    });

    const query = '''
SELECT 
  table_name,
  CASE 
    WHEN table_name IN (
      'chat_messages', 'chat_participants', 'chat_rooms',
      'dating_matches', 'dating_preferences', 'dating_swipes',
      'discussion_replies', 'gift_types', 'group_activity_log',
      'group_discussions', 'group_join_requests', 'group_meetings',
      'group_resources', 'interests', 'likes', 'live_stream_banned_users',
      'live_stream_gifts', 'live_stream_messages', 'live_stream_moderators',
      'live_streams', 'live_streams_enhanced', 'profiles', 'study_groups',
      'spiritual_posts', 'spiritual_post_likes', 'spiritual_post_comments',
      'spiritual_post_bookmarks', 'spiritual_post_shares', 'spiritual_post_reports'
    ) THEN 'EXISTS'
    ELSE 'MISSING'
  END as status
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name IN (
  'chat_messages', 'chat_participants', 'chat_rooms',
  'dating_matches', 'dating_preferences', 'dating_swipes',
  'discussion_replies', 'gift_types', 'group_activity_log',
  'group_discussions', 'group_join_requests', 'group_meetings',
  'group_resources', 'interests', 'likes', 'live_stream_banned_users',
  'live_stream_gifts', 'live_stream_messages', 'live_stream_moderators',
  'live_streams', 'live_streams_enhanced', 'profiles', 'study_groups',
  'spiritual_posts', 'spiritual_post_likes', 'spiritual_post_comments',
  'spiritual_post_bookmarks', 'spiritual_post_shares', 'spiritual_post_reports'
)
ORDER BY table_name;
    ''';

    try {
      final response = await SupabaseService.supabase
          .rpc('execute_sql', params: {'query': query});

      if (response is List) {
        setState(() {
          _queryResults = List<Map<String, dynamic>>.from(response);
          _showResults = true;
        });
      } else {
        setState(() {
          _queryResults = [{'result': response.toString()}];
          _showResults = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _insertPredefinedQuery(String query) {
    _sqlController.text = query;
    _sqlController.selection = TextSelection.fromPosition(
      TextPosition(offset: _sqlController.text.length),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado al portapapeles')),
    );
  }

  Widget _buildQueryResults() {
    if (_queryResults.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Resultados (${_queryResults.length} filas)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyToClipboard(_queryResults.toString()),
                  icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                  tooltip: 'Copiar resultados',
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _resultScrollController,
              child: SingleChildScrollView(
                controller: _resultScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[800]),
                    dataRowColor: MaterialStateProperty.all(Colors.grey[900]),
                    columns: _queryResults.isNotEmpty
                        ? _queryResults.first.keys.map((key) => DataColumn(
                            label: Text(
                              key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )).toList()
                        : [],
                    rows: _queryResults.map((row) => DataRow(
                      cells: row.values.map((value) => DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            value?.toString() ?? 'NULL',
                            style: TextStyle(
                              color: value == null ? Colors.grey : Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )).toList(),
                    )).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickActionButton('Verificar Tablas Faltantes', '''
-- Verificar qué tablas faltan
WITH expected_tables AS (
    SELECT unnest(ARRAY[
        'spiritual_posts', 'spiritual_post_likes', 'spiritual_post_comments',
        'spiritual_post_bookmarks', 'spiritual_post_shares', 'spiritual_post_reports',
        'study_groups', 'study_group_members', 'live_streams_enhanced',
        'live_stream_gifts', 'live_stream_messages', 'video_calls',
        'group_calls', 'payment_methods', 'digital_transactions',
        'dating_preferences', 'dating_swipes', 'dating_matches',
        'user_wallets', 'gift_types', 'profiles', 'chat_rooms',
        'chat_messages', 'chat_participants', 'files'
    ]) AS table_name
),
existing_tables AS (
    SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'
)
SELECT e.table_name AS "TABLA FALTANTE"
FROM expected_tables e
LEFT JOIN existing_tables ex ON e.table_name = ex.table_name
WHERE ex.table_name IS NULL
ORDER BY e.table_name;
            '''),
            _buildQuickActionButton('Listar Tablas Existentes', 'SELECT table_name, table_type FROM information_schema.tables WHERE table_schema = \'public\' ORDER BY table_name;'),
            _buildQuickActionButton('Verificar Tabla FILES', '''
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'files') 
        THEN 'La tabla FILES existe ✓'
        ELSE 'La tabla FILES NO existe ✗'
    END AS "Estado de tabla FILES";
            '''),
            _buildQuickActionButton('Ver Usuarios', 'SELECT id, email, created_at FROM auth.users LIMIT 10;'),
            _buildQuickActionButton('Estadísticas DB', 'SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del FROM pg_stat_user_tables ORDER BY tablename;'),
            _buildQuickActionButton('Crear Tabla FILES', '''
CREATE TABLE IF NOT EXISTS files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    path TEXT NOT NULL,
    size BIGINT,
    mime_type TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    bucket TEXT DEFAULT 'uploads',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE files ENABLE ROW LEVEL SECURITY;

-- Política básica de acceso
CREATE POLICY "Users can manage their own files" ON files
    FOR ALL USING (auth.uid() = user_id);
            '''),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, String query) {
    return ElevatedButton(
      onPressed: () {
        _sqlController.text = query;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Editor SQL', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _executeQuery,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : const Icon(Icons.play_arrow, color: Colors.green),
            tooltip: 'Ejecutar consulta',
          ),
          IconButton(
            onPressed: () {
              _sqlController.clear();
              setState(() {
                _queryResults.clear();
                _errorMessage = '';
                _showResults = false;
              });
            },
            icon: const Icon(Icons.clear, color: Colors.red),
            tooltip: 'Limpiar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 20),

            // Editor SQL
            const Text(
              'Consulta SQL:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: TextField(
                controller: _sqlController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                  hintText: 'Escribe tu consulta SQL aquí...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón ejecutar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _executeQuery,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isLoading ? 'Ejecutando...' : 'Ejecutar Consulta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkMissingTables,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_isLoading ? 'Verificando...' : 'Verificar Tablas'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            // Results
            if (_showResults) ...[
              const SizedBox(height: 16),
              Expanded(child: _buildQueryResults()),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sqlController.dispose();
    _resultScrollController.dispose();
    super.dispose();
  }
}