import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'testimonio_form.dart';

class TestimoniosListScreen extends StatefulWidget {
  const TestimoniosListScreen({super.key});

  @override
  State<TestimoniosListScreen> createState() => _TestimoniosListScreenState();
}

class _TestimoniosListScreenState extends State<TestimoniosListScreen> {
  List<Map<String, dynamic>> testimonios = [];
  List<Map<String, dynamic>> filteredTestimonios = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'todos'; // todos, aprobados, pendientes

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTestimonios();
  }

  Future<void> _loadTestimonios() async {
    try {
      setState(() => isLoading = true);

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('testimonios')
          .select('*')
          .order('created_at', ascending: false);

      setState(() {
        testimonios = List<Map<String, dynamic>>.from(response);
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar testimonios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    filteredTestimonios = testimonios.where((testimonio) {
      final matchesSearch =
          (testimonio['title']?.toString() ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
              (testimonio['content']?.toString() ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
              (testimonio['author_name']?.toString() ?? '').toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter = selectedFilter == 'todos' ||
          (selectedFilter == 'aprobados' && (testimonio['approved'] == true)) ||
          (selectedFilter == 'pendientes' && (testimonio['approved'] != true));

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      _applyFilters();
    });
  }

  Future<void> _toggleApproval(Map<String, dynamic> testimonio) async {
    try {
      final supabase = Supabase.instance.client;
      final newStatus = !(testimonio['approved'] == true);

      await supabase
          .from('testimonios')
          .update({'approved': newStatus})
          .eq('id', testimonio['id']);

      setState(() {
        testimonio['approved'] = newStatus;
        _applyFilters();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Testimonio aprobado' : 'Testimonio rechazado',
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTestimonioDetail(Map<String, dynamic> testimonio) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Detalle del Testimonio',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const FaIcon(FontAwesomeIcons.times, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                testimonio['title'] ?? 'Sin título',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    testimonio['content'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  FaIcon(FontAwesomeIcons.user, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    testimonio['author_name'] ?? 'Anónimo',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (testimonio['approved'] == true)
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (testimonio['approved'] == true) ? 'Aprobado' : 'Pendiente',
                      style: TextStyle(
                        color: (testimonio['approved'] == true) ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Barra de búsqueda
              TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar testimonios...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const FaIcon(FontAwesomeIcons.search, color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filtros
              Row(
                children: [
                  _buildFilterChip('todos', 'Todos', FontAwesomeIcons.list),
                  const SizedBox(width: 8),
                  _buildFilterChip('aprobados', 'Aprobados', FontAwesomeIcons.check),
                  const SizedBox(width: 8),
                  _buildFilterChip('pendientes', 'Pendientes', FontAwesomeIcons.clock),
                ],
              ),
            ],
          ),
        ),

        // Lista de testimonios
        Expanded(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          )
              : filteredTestimonios.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.comments,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron testimonios',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchQuery.isNotEmpty
                      ? 'Intenta con otros términos de búsqueda'
                      : 'Aún no hay testimonios registrados',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadTestimonios,
            color: Colors.amber,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredTestimonios.length,
              itemBuilder: (context, index) {
                final testimonio = filteredTestimonios[index];
                return _buildTestimonioCard(testimonio);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[600]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 14,
              color: isSelected ? Colors.amber : Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.grey[400],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonioCard(Map<String, dynamic> testimonio) {
    final isApproved = testimonio['approved'] == true;
    final createdAt = DateTime.parse(testimonio['created_at']);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showTestimonioDetail(testimonio),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y fecha
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          isApproved ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
                          size: 12,
                          color: isApproved ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isApproved ? 'Aprobado' : 'Pendiente',
                          style: TextStyle(
                            color: isApproved ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _toggleApproval(testimonio),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FaIcon(
                        isApproved ? FontAwesomeIcons.times : FontAwesomeIcons.check,
                        size: 12,
                        color: isApproved ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                testimonio['title'] ?? 'Sin título',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Contenido
              Text(
                testimonio['content'] ?? '',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer con autor y calificación
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.user,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    testimonio['author_name'] ?? 'Anónimo',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (testimonio['experience_rating'] != null) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: List.generate(5, (index) {
                        final rating = testimonio['experience_rating'] as int? ?? 0;
                        return FaIcon(
                          index <= rating ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                          size: 12,
                          color: index <= rating ? Colors.amber : Colors.grey[600],
                        );
                      }),
                    ),
                  ],
                  const Spacer(),
                  FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}