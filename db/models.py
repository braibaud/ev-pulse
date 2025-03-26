from typing import Any, List, Optional

from sqlalchemy import Boolean, CheckConstraint, Column, ForeignKeyConstraint, Index, Integer, PrimaryKeyConstraint, REAL, Table, Text, UniqueConstraint, Uuid, text, func
from sqlalchemy.orm import DeclarativeBase, Mapped, MappedAsDataclass, mapped_column, relationship, Session
from sqlalchemy.sql.sqltypes import NullType
from sqlalchemy.types import TypeDecorator, String
from sqlalchemy.dialects.postgresql import UUID
import uuid
import json
import dataclasses


class Base(MappedAsDataclass, DeclarativeBase):
    pass


@dataclasses.dataclass
class EntityKey:
    id: uuid.UUID
    entity_type_id: int


class EntityKeyType(TypeDecorator):
    impl = String  # Use String as the underlying type for storage

    def process_bind_param(self, value, dialect):
        if value is not None:
            if not isinstance(value, EntityKey):
                raise ValueError("Expected an EntityKey instance")
            # Convert the EntityKey instance to a JSON string
            return json.dumps({"id": str(value.id), "entity_type_id": value.entity_type_id})
        return value

    def process_result_value(self, value, dialect):
        if value is not None:
            # Convert the JSON string back to an EntityKey instance
            data = json.loads(value)
            return EntityKey(id=uuid.UUID(data["id"]), entity_type_id=data["entity_type_id"])
        return value


class RelatedEntities(Base):
    __tablename__ = 'related_entities'
    __table_args__ = (
        ForeignKeyConstraint(['entity1_key'], ['dbo.entity.key'],
                             name='fk_related_entities_entity1_key_entity'),
        ForeignKeyConstraint(['entity2_key'], ['dbo.entity.key'],
                             name='fk_related_entities_entity2_key_entity'),
        PrimaryKeyConstraint('entity1_key', 'entity2_key',
                             name='pk_related_entities'),
        Index('ix_related_entities_entity1_key', 'entity1_key'),
        Index('ix_related_entities_entity2_key', 'entity2_key'),
        {'schema': 'dbo'}
    )

    entity1_key: Mapped[EntityKey] = mapped_column(
        EntityKeyType, primary_key=True, nullable=False)
    entity2_key: Mapped[EntityKey] = mapped_column(
        EntityKeyType, primary_key=True, nullable=False)


class Entity(Base):
    __tablename__ = 'entity'
    __table_args__ = (
        CheckConstraint('(key).entity_type_id IS NOT NULL',
                        name='ck_entity_key_entity_type_id_not_null'),
        ForeignKeyConstraint(['parent_key'], ['dbo.entity.key'],
                             name='fk_entity_parent_key_entity'),
        PrimaryKeyConstraint('key', name='pk_entity'),
        Index('ix_entity_parent_key', 'parent_key'),
        Index('ux_entity_name_entity_type_id', 'name', unique=True),
        {'schema': 'dbo'}
    )

    key: Mapped[EntityKey] = mapped_column(
        EntityKeyType, primary_key=True)
    name: Mapped[str] = mapped_column(Text)
    is_virtual: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    parent_key: Mapped[Optional[EntityKeyType]
                       ] = mapped_column(EntityKeyType)
    description: Mapped[Optional[str]] = mapped_column(Text)

    children: Mapped[List['Entity']] = relationship(
        'Entity', back_populates='parent', remote_side=[key])
    parent: Mapped[Optional['Entity']] = relationship(
        'Entity', back_populates='children', remote_side=[parent_key])

    related_entities: Mapped[List['Entity']] = relationship(
        'Entity',
        secondary=RelatedEntities.__table__,
        primaryjoin=lambda: Entity.key == RelatedEntities.entity1_key,
        secondaryjoin=lambda: Entity.key == RelatedEntities.entity2_key,
        viewonly=False
    )

    vehicle_part: Mapped[List['VehiclePart']] = relationship(
        'VehiclePart', back_populates='entity')
    entity_attribute: Mapped[List['EntityAttribute']] = relationship(
        'EntityAttribute', back_populates='entity')
    entity_feature: Mapped[List['EntityFeature']] = relationship(
        'EntityFeature', back_populates='entity')


class EntityType(Base):
    __tablename__ = 'entity_type'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='pk_entity_type'),
        UniqueConstraint('name', name='uk_entity_type_name'),
        {'schema': 'dbo'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    name: Mapped[str] = mapped_column(Text)


class Group(Base):
    __tablename__ = 'group'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='pk_group'),
        {'schema': 'dbo'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    name: Mapped[str] = mapped_column(Text)

    attribute: Mapped[List['Attribute']] = relationship(
        'Attribute', back_populates='group')
    feature: Mapped[List['Feature']] = relationship(
        'Feature', back_populates='group')


class Vehicle(Base):
    __tablename__ = 'vehicle'
    __table_args__ = (
        PrimaryKeyConstraint('vehicle_id', name='pk_vehicle'),
        Index('ix_vehicle_name', 'name'),
        {'schema': 'dbo'}
    )

    vehicle_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, primary_key=True, server_default=text('gen_random_uuid()'))
    name: Mapped[str] = mapped_column(Text)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    description: Mapped[Optional[str]] = mapped_column(Text)

    vehicle_part: Mapped[List['VehiclePart']] = relationship(
        'VehiclePart', back_populates='vehicle')
    vehicle_attribute: Mapped[List['VehicleAttribute']] = relationship(
        'VehicleAttribute', back_populates='vehicle')
    vehicle_feature: Mapped[List['VehicleFeature']] = relationship(
        'VehicleFeature', back_populates='vehicle')


class Attribute(Base):
    __tablename__ = 'attribute'
    __table_args__ = (
        ForeignKeyConstraint(['group_id'], ['dbo.group.id'],
                             name='fk_attribute_group_group'),
        PrimaryKeyConstraint('id', name='pk_attribute'),
        UniqueConstraint('name', name='uk_attribute_name'),
        Index('ix_attribute_group_id', 'group_id'),
        {'schema': 'dbo'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    name: Mapped[str] = mapped_column(Text)
    is_inheritable: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    is_overridable: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    group_id: Mapped[int] = mapped_column(Integer)
    default_unit: Mapped[Optional[str]] = mapped_column(Text)
    description: Mapped[Optional[str]] = mapped_column(Text)

    group: Mapped['Group'] = relationship('Group', back_populates='attribute')
    entity_attribute: Mapped[List['EntityAttribute']] = relationship(
        'EntityAttribute', back_populates='attribute')
    vehicle_attribute: Mapped[List['VehicleAttribute']] = relationship(
        'VehicleAttribute', back_populates='attribute')


class Feature(Base):
    __tablename__ = 'feature'
    __table_args__ = (
        ForeignKeyConstraint(['group_id'], ['dbo.group.id'],
                             name='fk_feature_group_group'),
        PrimaryKeyConstraint('id', name='pk_feature'),
        UniqueConstraint('name', name='uk_feature_name'),
        Index('ix_feature_group_id', 'group_id'),
        {'schema': 'dbo'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    name: Mapped[str] = mapped_column(Text)
    is_inheritable: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    is_overridable: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    group_id: Mapped[int] = mapped_column(Integer)
    default_currency: Mapped[Optional[str]] = mapped_column(Text)
    description: Mapped[Optional[str]] = mapped_column(Text)

    group: Mapped['Group'] = relationship('Group', back_populates='feature')
    entity_feature: Mapped[List['EntityFeature']] = relationship(
        'EntityFeature', back_populates='feature')
    vehicle_feature: Mapped[List['VehicleFeature']] = relationship(
        'VehicleFeature', back_populates='feature')


class VehiclePart(Base):
    __tablename__ = 'vehicle_part'
    __table_args__ = (
        ForeignKeyConstraint(['entity_key'], ['dbo.entity.key'],
                             name='fk_vehicle_part_entity_entity'),
        ForeignKeyConstraint(['vehicle_id'], [
                             'dbo.vehicle.vehicle_id'], name='fk_vehicle_part_vehicle_id_vehicle'),
        PrimaryKeyConstraint('vehicle_id', 'entity_key',
                             name='pk_vehicle_part'),
        Index('ix_vehicle_part_entity_key', 'entity_key'),
        Index('ix_vehicle_part_vehicle_id', 'vehicle_id'),
        {'schema': 'dbo'}
    )

    vehicle_id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True)
    entity_key: Mapped[EntityKey] = mapped_column(
        EntityKeyType, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))

    entity: Mapped['Entity'] = relationship(
        'Entity', back_populates='vehicle_part')
    vehicle: Mapped['Vehicle'] = relationship(
        'Vehicle', back_populates='vehicle_part')


class EntityAttribute(Base):
    __tablename__ = 'entity_attribute'
    __table_args__ = (
        ForeignKeyConstraint(['attribute_id'], [
                             'dbo.attribute.id'], name='fk_entity_attribute_attribute_attribute'),
        ForeignKeyConstraint(['entity_key'], ['dbo.entity.key'],
                             name='fk_entity_attribute_entity_entity'),
        PrimaryKeyConstraint('entity_key', 'attribute_id',
                             name='pk_entity_attribute'),
        Index('ix_entity_attribute_attribute_id', 'attribute_id'),
        Index('ix_entity_attribute_entity_key', 'entity_key'),
        {'schema': 'dbo'}
    )

    entity_key: Mapped[EntityKey] = mapped_column(
        EntityKeyType, primary_key=True)
    attribute_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    value: Mapped[Optional[str]] = mapped_column(Text)
    unit: Mapped[Optional[str]] = mapped_column(Text)

    attribute: Mapped['Attribute'] = relationship(
        'Attribute', back_populates='entity_attribute')
    entity: Mapped['Entity'] = relationship(
        'Entity', back_populates='entity_attribute')


class EntityFeature(Base):
    __tablename__ = 'entity_feature'
    __table_args__ = (
        ForeignKeyConstraint(['entity_key'], ['dbo.entity.key'],
                             name='fk_entity_feature_entity_entity'),
        ForeignKeyConstraint(['feature_id'], ['dbo.feature.id'],
                             name='fk_entity_feature_feature_feature'),
        PrimaryKeyConstraint('entity_key', 'feature_id',
                             name='pk_entity_feature'),
        Index('ix_entity_feature_entity_key', 'entity_key'),
        Index('ix_entity_feature_feature_id', 'feature_id'),
        {'schema': 'dbo'}
    )

    entity_key: Mapped[EntityKey] = mapped_column(
        EntityKeyType, primary_key=True)
    feature_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    price: Mapped[Optional[float]] = mapped_column(REAL)
    currency: Mapped[Optional[str]] = mapped_column(Text)

    entity: Mapped['Entity'] = relationship(
        'Entity', back_populates='entity_feature')
    feature: Mapped['Feature'] = relationship(
        'Feature', back_populates='entity_feature')


class VehicleAttribute(Base):
    __tablename__ = 'vehicle_attribute'
    __table_args__ = (
        ForeignKeyConstraint(['attribute_id'], [
                             'dbo.attribute.id'], name='fk_vehicle_attribute_attribute_id_attribute'),
        ForeignKeyConstraint(['vehicle_id'], [
                             'dbo.vehicle.vehicle_id'], name='fk_vehicle_attribute_vehicle_id_vehicle'),
        PrimaryKeyConstraint('vehicle_id', 'attribute_id',
                             name='pk_vehicle_attribute'),
        Index('ix_vehicle_attribute_vehicle_id', 'vehicle_id'),
        {'schema': 'dbo'}
    )

    vehicle_id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True)
    attribute_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    value: Mapped[str] = mapped_column(Text)
    unit: Mapped[Optional[str]] = mapped_column(Text)

    attribute: Mapped['Attribute'] = relationship(
        'Attribute', back_populates='vehicle_attribute')
    vehicle: Mapped['Vehicle'] = relationship(
        'Vehicle', back_populates='vehicle_attribute')


class VehicleFeature(Base):
    __tablename__ = 'vehicle_feature'
    __table_args__ = (
        ForeignKeyConstraint(['feature_id'], ['dbo.feature.id'],
                             name='fk_vehicle_feature_feature_id_feature'),
        ForeignKeyConstraint(['vehicle_id'], [
                             'dbo.vehicle.vehicle_id'], name='fk_vehicle_feature_vehicle_id_vehicle'),
        PrimaryKeyConstraint('vehicle_id', 'feature_id',
                             name='pk_vehicle_feature'),
        Index('ix_vehicle_feature_feature_id', 'feature_id'),
        Index('ix_vehicle_feature_vehicle_id', 'vehicle_id'),
        {'schema': 'dbo'}
    )

    vehicle_id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True)
    feature_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    is_optional: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    is_active: Mapped[bool] = mapped_column(
        Boolean, server_default=text('true'))
    price: Mapped[float] = mapped_column(REAL)
    currency: Mapped[Optional[str]] = mapped_column(Text)

    feature: Mapped['Feature'] = relationship(
        'Feature', back_populates='vehicle_feature')
    vehicle: Mapped['Vehicle'] = relationship(
        'Vehicle', back_populates='vehicle_feature')


def assign_entity_attributes(session: Session, p_entity_key: EntityKey, p_entity_attributes: List[dict], p_add_or_replace_attributes: str = 'ADD'):
    result = session.execute(
        func.dbo.assign_entity_attributes(
            p_entity_key, p_entity_attributes, p_add_or_replace_attributes)
    )
    return [EntityAttribute(**row._mapping) for row in result]


def assign_entity_features(session: Session, p_entity_key: EntityKey, p_entity_features: List[dict], p_add_or_replace_features: str = 'ADD'):
    result = session.execute(
        func.dbo.assign_entity_features(
            p_entity_key, p_entity_features, p_add_or_replace_features)
    )
    return [EntityFeature(**row._mapping) for row in result]


def create_attribute(session: Session, p_name: str, p_group_name: str, p_default_unit: Optional[str], p_is_active: bool = True, p_is_inheritable: bool = True, p_is_overridable: bool = True):
    result = session.execute(
        func.dbo.create_attribute(
            p_name, p_group_name, p_default_unit, p_is_active, p_is_inheritable, p_is_overridable)
    )
    return result.scalar_one_or_none()


def create_entity(session: Session, p_name: str, p_entity_type_name: str, p_parent_key: Optional[EntityKey], p_is_virtual: bool, p_is_active: bool):
    result = session.execute(
        func.dbo.create_entity(p_name, p_entity_type_name,
                               p_parent_key, p_is_virtual, p_is_active)
    )
    return Entity(**result.scalar_one_or_none()._mapping) if result.scalar_one_or_none() else None


def create_feature(session: Session, p_name: str, p_group_name: str, p_default_currency: Optional[str], p_is_active: bool = True, p_is_inheritable: bool = True, p_is_overridable: bool = True):
    result = session.execute(
        func.dbo.create_feature(p_name, p_group_name, p_default_currency,
                                p_is_active, p_is_inheritable, p_is_overridable)
    )
    return result.scalar_one_or_none()


def create_option_pack(session: Session, p_parent_entity_key: EntityKey, p_option_pack_name: str, p_feature_names: List[str], p_add_or_replace_features: str = 'ADD'):
    result = session.execute(
        func.dbo.create_option_pack(
            p_parent_entity_key, p_option_pack_name, p_feature_names, p_add_or_replace_features)
    )
    return Entity(**result.scalar_one_or_none()._mapping) if result.scalar_one_or_none() else None


def create_vehicule(session: Session, p_name: str, p_entities: List[EntityKey], p_is_active: bool = True):
    result = session.execute(
        func.dbo.create_vehicule(p_name, p_entities, p_is_active)
    )
    return result.scalar_one_or_none()


def get_attribute_id(session: Session, p_attribute_name: str):
    result = session.execute(
        func.dbo.get_attribute_id(p_attribute_name)
    )
    return result.scalar_one_or_none()


def get_entity_attributes(session: Session, p_key: EntityKey):
    result = session.execute(
        func.dbo.get_entity_attributes(p_key)
    )
    return [EntityAttribute(**row._mapping) for row in result]


def get_entity_features(session: Session, p_key: EntityKey):
    result = session.execute(
        func.dbo.get_entity_features(p_key)
    )
    return [EntityFeature(**row._mapping) for row in result]


def get_entity_type_id(session: Session, p_entity_type_name: str):
    result = session.execute(
        func.dbo.get_entity_type_id(p_entity_type_name)
    )
    return result.scalar_one_or_none()


def get_entity_type_name(session: Session, p_entity_type_id: int):
    result = session.execute(
        func.dbo.get_entity_type_name(p_entity_type_id)
    )
    return result.scalar_one_or_none()


def get_feature_id(session: Session, p_feature_name: str):
    result = session.execute(
        func.dbo.get_feature_id(p_feature_name)
    )
    return result.scalar_one_or_none()


def get_nearest_parent(session: Session, p_key: EntityKey, p_target_entity_type_id: int, p_max_depth: int = 10):
    result = session.execute(
        func.dbo.get_nearest_parent(
            p_key, p_target_entity_type_id, p_max_depth)
    )
    return Entity(**result.scalar_one_or_none()._mapping) if result.scalar_one_or_none() else None


def get_nearest_parent_entity(session: Session, p_key: EntityKey, p_target_entity_type_id: int, p_max_depth: int = 10):
    result = session.execute(
        func.dbo.get_nearest_parent_entity(
            p_key, p_target_entity_type_id, p_max_depth)
    )
    return Entity(**result.fetchone()._mapping) if result.fetchone() else None


def get_vehicle_attributes(session: Session, p_vehicle_id: uuid.UUID):
    result = session.execute(
        func.dbo.get_vehicle_attributes(p_vehicle_id)
    )
    return [VehicleAttribute(**row._mapping) for row in result]


def get_vehicle_features(session: Session, p_vehicle_id: uuid.UUID):
    result = session.execute(
        func.dbo.get_vehicle_features(p_vehicle_id)
    )
    return [VehicleFeature(**row._mapping) for row in result]


def set_entity_attribute_value(session: Session, p_key: EntityKey, p_attribute_id: int, p_value: str, p_unit: Optional[str], p_propagate_down: bool = False):
    session.execute(
        func.dbo.set_entity_attribute_value(
            p_key, p_attribute_id, p_value, p_unit, p_propagate_down)
    )
    session.commit()


def set_entity_feature_value(session: Session, p_key: EntityKey, p_feature_id: int, p_price: float, p_currency: Optional[str], p_propagate_down: bool = False):
    session.execute(
        func.dbo.set_entity_feature_value(
            p_key, p_feature_id, p_price, p_currency, p_propagate_down)
    )
    session.commit()


def set_vehicle_attribute_value(session: Session, p_vehicle_id: uuid.UUID, p_attribute_id: int, p_value: str, p_unit: Optional[str]):
    session.execute(
        func.dbo.set_vehicle_attribute_value(
            p_vehicle_id, p_attribute_id, p_value, p_unit)
    )
    session.commit()


def set_vehicle_feature_value(session: Session, p_vehicle_id: uuid.UUID, p_feature_id: int, p_price: float, p_currency: Optional[str]):
    session.execute(
        func.dbo.set_vehicle_feature_value(
            p_vehicle_id, p_feature_id, p_price, p_currency)
    )
    session.commit()
