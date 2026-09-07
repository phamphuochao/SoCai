class BusinessError(Exception):
    """
    Lỗi nghiệp vụ (VD: bán vượt tồn kho, giảm giá lớn hơn tổng tiền...).
    Router sẽ bắt exception này và trả về HTTP 400 kèm thông báo rõ ràng,
    thay vì để lộ traceback kỹ thuật ra ngoài.
    """
    pass
