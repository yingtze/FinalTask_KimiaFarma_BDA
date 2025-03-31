-- Buat tabel analisa untuk laporan transaksi Kimia Farma
CREATE OR REPLACE TABLE kimia_farma.kf_analisa AS
SELECT
    ft.transaction_id,
    ft.date,
    kc.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating AS rating_cabang,
    ft.customer_name,
    p.product_id,
    p.product_name,
    ft.price AS actual_price,
    ft.discount_percentage,
    
    -- Menentukan persentase laba kotor berdasarkan tier harga produk
    CASE
        WHEN ft.price <= 50000 THEN 10
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 20
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 25
        ELSE 30
    END AS persentase_gross_laba,
    
    -- Menghitung penjualan bersih setelah diskon diterapkan
    ROUND(ft.price * (1 - (ft.discount_percentage / 100)), 2) AS nett_sales,
    
    -- Menghitung keuntungan bersih dari penjualan sesuai tier persentase laba
    ROUND((ft.price * (1 - (ft.discount_percentage / 100))) * 
    CASE
        WHEN ft.price <= 50000 THEN 0.10
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.20
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25
        ELSE 0.30
    END, 2) AS nett_profit,
    
    ft.rating AS rating_transaksi
FROM 
    kimia_farma.kf_final_transaction ft     -- kt = transaksi final
LEFT JOIN 
    kimia_farma.kf_kantor_cabang kc ON ft.branch_id = kc.branch_id    -- kc = kantor cabang
LEFT JOIN 
    kimia_farma.kf_product p ON ft.product_id = p.product_id;       -- p = produk
