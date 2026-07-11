abstract final class PendingEntity {
  static const recipe = 'recipe';
  static const planSlot = 'plan_slot';
  static const shoppingList = 'shopping_list';
  static const shoppingItem = 'shopping_item';
}

abstract final class PendingOp {
  static const create = 'create';
  static const update = 'update';
  static const delete = 'delete';
  static const add = 'add';
  static const remove = 'remove';
  static const toggle = 'toggle';
  static const clear = 'clear';
}
