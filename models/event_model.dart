import 'package:flutter/material.dart';

enum EventType {
  culto,
  conferencia,
  retiro,
  seminario,
  mision,
  juvenil,
  familiar,
  especial
}

enum EventStatus {
  proximo,
  enVivo,
  finalizado,
  cancelado
}

class EventModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String descripcionCorta;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String ubicacion;
  final String direccion;
  final String imagenUrl;
  final EventType tipo;
  final EventStatus estado;
  final double precio;
  final bool esPremium;
  final bool requiresRegistration;
  final int capacidadMaxima;
  final int registrados;
  final List<String> tags;
  final String? linkTransmision;
  final String? contactoInfo;
  final String? organizador;

  const EventModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.descripcionCorta,
    required this.fechaInicio,
    required this.fechaFin,
    required this.ubicacion,
    required this.direccion,
    required this.imagenUrl,
    required this.tipo,
    required this.estado,
    this.precio = 0.0,
    this.esPremium = false,
    this.requiresRegistration = false,
    this.capacidadMaxima = 0,
    this.registrados = 0,
    this.tags = const [],
    this.linkTransmision,
    this.contactoInfo,
    this.organizador,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      descripcionCorta: json['descripcion_corta'] ?? '',
      fechaInicio: DateTime.parse(json['fecha_inicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: DateTime.parse(json['fecha_fin'] ?? DateTime.now().toIso8601String()),
      ubicacion: json['ubicacion'] ?? '',
      direccion: json['direccion'] ?? '',
      imagenUrl: json['imagen_url'] ?? '',
      tipo: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipo'],
        orElse: () => EventType.culto,
      ),
      estado: EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['estado'],
        orElse: () => EventStatus.proximo,
      ),
      precio: (json['precio'] ?? 0.0).toDouble(),
      esPremium: json['es_premium'] ?? false,
      requiresRegistration: json['requires_registration'] ?? false,
      capacidadMaxima: json['capacidad_maxima'] ?? 0,
      registrados: json['registrados'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      linkTransmision: json['link_transmision'],
      contactoInfo: json['contacto_info'],
      organizador: json['organizador'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'descripcion_corta': descripcionCorta,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'ubicacion': ubicacion,
      'direccion': direccion,
      'imagen_url': imagenUrl,
      'tipo': tipo.toString().split('.').last,
      'estado': estado.toString().split('.').last,
      'precio': precio,
      'es_premium': esPremium,
      'requires_registration': requiresRegistration,
      'capacidad_maxima': capacidadMaxima,
      'registrados': registrados,
      'tags': tags,
      'link_transmision': linkTransmision,
      'contacto_info': contactoInfo,
      'organizador': organizador,
    };
  }

  // Getters útiles
  String get tipoTexto {
    switch (tipo) {
      case EventType.culto:
        return 'Culto';
      case EventType.conferencia:
        return 'Conferencia';
      case EventType.retiro:
        return 'Retiro';
      case EventType.seminario:
        return 'Seminario';
      case EventType.mision:
        return 'Misión';
      case EventType.juvenil:
        return 'Evento Juvenil';
      case EventType.familiar:
        return 'Evento Familiar';
      case EventType.especial:
        return 'Evento Especial';
    }
  }

  String get estadoTexto {
    switch (estado) {
      case EventStatus.proximo:
        return 'Próximo';
      case EventStatus.enVivo:
        return 'En Vivo';
      case EventStatus.finalizado:
        return 'Finalizado';
      case EventStatus.cancelado:
        return 'Cancelado';
    }
  }

  Color get tipoColor {
    switch (tipo) {
      case EventType.culto:
        return const Color(0xFFFFD700); // Dorado
      case EventType.conferencia:
        return const Color(0xFF9C27B0); // Púrpura
      case EventType.retiro:
        return const Color(0xFF4CAF50); // Verde
      case EventType.seminario:
        return const Color(0xFF2196F3); // Azul
      case EventType.mision:
        return const Color(0xFFFF5722); // Naranja
      case EventType.juvenil:
        return const Color(0xFFE91E63); // Rosa
      case EventType.familiar:
        return const Color(0xFF795548); // Marrón
      case EventType.especial:
        return const Color(0xFFFFD700); // Dorado especial
    }
  }

  Color get estadoColor {
    switch (estado) {
      case EventStatus.proximo:
        return const Color(0xFF4CAF50); // Verde
      case EventStatus.enVivo:
        return const Color(0xFFFF5722); // Rojo en vivo
      case EventStatus.finalizado:
        return const Color(0xFF9E9E9E); // Gris
      case EventStatus.cancelado:
        return const Color(0xFFF44336); // Rojo cancelado
    }
  }

  bool get isAvailable {
    return estado == EventStatus.proximo || estado == EventStatus.enVivo;
  }

  bool get hasAvailableSeats {
    if (capacidadMaxima == 0) return true;
    return registrados < capacidadMaxima;
  }

  String get duracionTexto {
    final duracion = fechaFin.difference(fechaInicio);
    if (duracion.inDays > 0) {
      return '${duracion.inDays} días';
    } else if (duracion.inHours > 0) {
      return '${duracion.inHours} horas';
    } else {
      return '${duracion.inMinutes} minutos';
    }
  }
}