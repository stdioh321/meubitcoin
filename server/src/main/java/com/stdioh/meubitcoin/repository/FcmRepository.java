package com.stdioh.meubitcoin.repository;

import com.stdioh.meubitcoin.model.Fcm;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.List;

@Repository
public interface FcmRepository extends JpaRepository<Fcm, String> {

        List<Fcm> findByIdDeviceAndCoinIgnoreCase(String idDevice, String coin);
}
