<?php
require_once 'common.php';
/** Zend_Application */
$application = new Zend_Application(
    APPLICATION_ENV, 
    APPLICATION_PATH . '/configs/application.ini'
);
$application->getBootstrap()->bootstrap(array(
    'topLevel', 'db','autoload','ssLoader', 'session', 'language', 'tz'
));

set_error_handler('errorHandler');
function errorHandler($errno, $errstr, $errfile, $errline) {
    //σε περίπτωση αδυναμίας σύνδεσης στη βάση πρέπει να μην φαίνονται τα στοιχεία σύνδεσης (username, password)
    $str = $errstr . ' in ' . $errfile . ' line '. $errline;
    throw new Zend_Amf_Server_Exception($str, $errno);
}

$server = new Zend_Amf_Server();
$server->setProduction(false);
$server->setSession();
$server->addFunction(array('pLogin', 
                        'pLogout',
                        'getSessionUser',
                        'checkAndAddUser',
                        'changeProfile',
                        'deleteUser',
                        'getGlobalTags',
                        'getUserTags',
                        'createUserTag',
                        'updateUserTag',
                        'deleteUserTag',
                        'getAlgorithm',
                        'deleteAlgorithm',
                        'saveAlgorithm',
                        'getUserAlgorithms',
                        'resetPassword',
                        'saveSettings'
                    )
);
try {
    $response = $server->handle();
}
catch(Exception $exception) {
    throw new Zend_Amf_Server_Exception($exception->getMessage(), $exception->getCode());   
}
echo $response;

function pLogin($username, $password, $rememberMe)
{
    $form = new Default_Form_Login(array('action' => 'null'));
    if($form->isValid(array('username'=>$username, 'password'=>$password))) { 
        $auth = Zend_Auth::getInstance();
        $authAdapter = new Zend_Auth_Adapter_DbTable(
            Zend_Registry::get('db'),'users','username','password', 'MD5(?)'
        );
        $authAdapter->setIdentity($username)->setCredential($password);
        $result = $auth->authenticate($authAdapter);
        if($result->getCode() == Zend_Auth_Result::SUCCESS) {
            $session = Zend_Registry::get('session');
            if($rememberMe) {
                Zend_Session::rememberMe(1209600);
            }
            $session->authUser = new Default_Model_User();
            $arr = (array)$authAdapter->getResultRowObject(null, array('password'));
            $session->authUser->mapProperties($arr);
            $session->authUser->settings = json_decode($session->authUser->settings);
            $session->isUserLogged = true;
            return true;            
        }else {
            return false;
        }
    }else {
        return false;
    }
}
function getSessionUserId() {
    $session = Zend_Registry::get('session');
    if(!$session->isUserLogged) {
        throw new Zend_Amf_Server_Exception('sessionError');
    }
    return $session->authUser->id;
}
function getFormMessages($form, $name)
{
    $str = "Τα ακόλουθα λάθη εμφανίστηκαν κατά την καταχώρηση : \n";
    $messages = $form->getMessages();
    //var_dump($messages);
    $messages = $messages[$name];
    foreach($messages as $key => $arr) {            
        foreach($arr as $msg) {
            $str .= $form->getElement($key)->getLabel(). ' : ' . $msg .". \n";          
        }
    }
    return $str;    
}
function pLogout()
{
    Zend_Auth::getInstance()->clearIdentity();
    return true;
}
function getSessionUser()
{
    if(Zend_Auth::getInstance()->hasIdentity()) {
        $session = Zend_Registry::get('session');
        $user = new Default_Model_Amf_User();
        $user->mapProperties((array)$session->authUser);
        return $user;
    }else {
        return null;
    }   
}
function checkAndAddUser($username, $firstName, $lastName, $password, $email, $settings)
{
    $user = new Default_Model_User();
    $form = $user->getForm(false);
    $form->setPostAction('new');
    if($form->isValid(array(
                        'username'=>$username,
                        'firstName' => $firstName,
                        'lastName'=>$lastName,
                        'password'=>$password,
                        'email'=>$email, 
                        'password'=>$password
                        ))) {
        $arr = $form->getValues();
        $user->mapProperties($arr['user']);
        $user->settings = $settings;
        $user->save();
        return true;        
    } else {
        return getFormMessages($form, 'user');
    }
}
function deleteUser($username)
{
    $session = Zend_Registry::get('session');
    if(!$session->authUser || $username != $session->authUser->username) {
        throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων');
    }
    $session->authUser->delete();
    return true;
}
function changeProfile($username, $firstName, $lastName, $password, $email)
{
    $session = Zend_Registry::get('session');
    if(!$session->authUser || $username != $session->authUser->username) {
        throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων');
    }
    if($email != $session->authUser->email) {
        $validator = new Zend_Validate_Db_NoRecordExists('users', 'email');
        if(!$validator->isValid($email)) {
            return 'Η διεύθυνση email που δώσατε χρησιμοποιείται ήδη';
        }
    }
    if($password) {
        $validator = new Zend_Validate_StringLength(6, 100);
        if(!$validator->isValid($password)) {
            throw new Zend_Amf_Server_Exception('Σφάλμα συνθηματικού');
        }
        $arr = array('firstName'=> $firstName, 'lastName' => $lastName, 'email'=>$email, 'password' => $password);
    }else {
        $arr = array('firstName'=> $firstName, 'lastName' => $lastName, 'email'=>$email);
    }
    $session->authUser->mapProperties($arr);
    $session->authUser->save();
    return true;
}
function resetPassword($email) {
    $ret = new stdClass();  
    $validator = new Zend_Validate_EmailAddress();
    if(!$validator->isValid($email)) {
        $ret->success = false;
        $ret->messages[0] = 'Λανθασμένη διεύθυνση email';
        return $ret;
    }
    $db = Zend_Registry::get('db');
    $user = new Default_Model_User();
    $where = $db->quoteInto('`email`= ?', $email);
    $user->fetchRow($where);    
    
    if($user->id) {
        $ret->success = true;
        $newPass = makePassword();
        $user->password = $newPass;
        $user->save();
        $body = "Το νέο σας συνθηματικό για τον τόπο www.pseudoglossa.gr είναι  : $newPass\n";
        $body .= 'Μπορείτε να αλλάξετε το συγκεκριμένο συνθηματικό επιλέγοντας "Αλλαγή Στοιχείων" μετά την είσοδό σας στο σύστημα.'."\n";
        $body .= 'Το όνομα χρήστη του λογαριασμού σας είναι : '. $user->username;       
        if(APPLICATION_ENV != 'staging') {
            $tr = new Zend_Mail_Transport_Smtp('mailgate.forthnet.gr');
            Zend_Mail::setDefaultTransport($tr);        
        }       
        $mail = new Zend_Mail('UTF-8');     
        $mail->setBodyText($body)
            ->setFrom('mailer@pseudoglossa.gr', 'pseudoglossa.gr')
            ->addTo($email, $user->firstName . ' ' . $user->lastName)
            ->setSubject('Αλλαγή κωδικού')
            ->send();
    }
    else {
        $ret->success = false;
        $ret->messages[0] = 'Η διεύθυνση δεν ανήκει σε κάποιον χρήστη';
    }
    return $ret;
}
function getGlobalTags()
{
    $table = new Default_Model_DbTable_GlobalTag();
    $rows = $table->fetchAll(null, 'order ASC');
    $ret = new stdClass();
    $ret->success = true;
    $ret->tags = $rows->toArray();
    return $ret;
}
function getUserTags()
{
    $userId = getSessionUserId();
    $table = new Default_Model_DbTable_UserTag();
    $rows = $table->fetchAll("userId = $userId", 'name ASC');
    $ret = new stdClass();
    $ret->success = true;
    $ret->tags = $rows->count() == 0 ? array() : $rows->toArray() ;
    return $ret;
}
function createUserTag($name)
{
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
    $userTag = new Default_Model_UserTag(); 
    $form = $userTag->getForm(false);
    $ret = new stdClass();
    if($form->isValid(array('name'=>$name))) {
        $clause = $db->quoteInto('userId = ?', $userId);
        $validator = new Zend_Validate_Db_NoRecordExists('user_tags', 'name', $clause);
        if(!$validator->isValid($name)) {
            $ret->success = false;
            $ret->messages = 'Υπάρχει ήδη μία ετικέτα με αυτό το όνομα';
        }
        else {
            $arr = $form->getValues();
            $arr['userTag']['userId'] = $userId;
            $userTag->mapProperties($arr['userTag']);
            $userTag->save();
            $ret->success = true;
            $ret->tags = getUserTags()->tags;
            $ret->tagId = $userTag->id;
        }
    } else {
        $ret->success = false;
        $ret->messages = getFormMessages($form, 'userTag');
    }
    return $ret;
}
function tagAlgorithm($algorithmId, $tagIds = array(), $tagType = 'global')
{
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
    if($tagType == 'global') {
        $relClass = 'Default_Model_AlgorithmsGlobalTags';
        $idField = 'globalTagId';
        $relTableClass = 'Default_Model_DbTable_AlgorithmsGlobalTags';
        $relTable = 'algorithms-global_tags';
    } else {
        $relClass = 'Default_Model_AlgorithmsUserTags';
        $idField = 'userTagId';
        $relTableClass = 'Default_Model_DbTable_AlgorithmsUserTags';
        $relTable = 'algorithms-user_tags';
    }
    $table = new $relTableClass(); 
    $table->delete("`algorithmId` = $algorithmId");  
    if(count($tagIds) > 0) {            
        $sql = "INSERT INTO `$relTable`(`algorithmId`,`$idField`)";
        $values = array();      
        $names = array();   
        foreach($tagIds as $tagId) {
            $values[] = "($algorithmId, $tagId)"; 
        }
        $sql .= 'VALUES '.implode(',', $values);
        $db->query($sql);                                   
    }   
    return true;
}
function updateUserTag($id,$name)
{   
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
    $userTag = new Default_Model_UserTag();
    $form = $userTag->getForm(false);   
    if($form->isValid(array('name'=>$name))) {
        $row = $userTag->find($id);
        if($row->userId == $userId) {
            if($row->name != $name) {
                $clause = $db->quoteInto('userId = ?', $userId);
                $validator = new Zend_Validate_Db_NoRecordExists('user_tags', 'name', $clause);
                if(!$validator->isValid($name)) {
                    $ret = new stdClass();
                    $ret->success = false;
                    $ret->tagId = $userTag->id;
                    $ret->messages[0] = 'Υπάρχει ήδη μία ετικέτα με αυτό το όνομα';
                    return $ret;
                }
            }
            $arr = $form->getValues();
            $arr['userTag']['userId'] = $userId;
            $arr['userTag']['id'] = $id;
            $userTag->mapProperties($arr['userTag']);
            $userTag->save();
            $ret = new stdClass();
            $ret->success = true;
            $ret->tagId = $userTag->id;
            $ret->tags = getUserTags()->tags;
            return $ret;
        } else {
            throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων');
        }
    } else {
        $ret = new stdClass();
        $ret->success = false;
        $ret->messages = getFormMessages($form, 'userTag');
        return $ret;
    }
}
function deleteUserTag($id)
{
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
    $table = new Default_Model_DbTable_UserTag();
    $where = $db->quoteInto('`id` = ?', $id).$db->quoteInto(' AND `userId` = ?', $userId);  
    $res = $table->delete($where);  
    if($res) {  
        $ret = new stdClass();
        $ret->success = true;
        $ret->tags = getUserTags()->tags;
        $ret->tagId = $id;
        return $ret;
    } else {
        throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων/Δεν βρέθηκε εγγραφή που να ικανοποιεί τα συγκεκριμένα κριτήρια');
    }   
}
function getAlgorithm($id)
{
    $userId = getSessionUserId();
    $db = Zend_Registry::get('db'); 
    $table = new Default_Model_DbTable_Algorithm();
    $row = $table->fetchRow(
        $db->quoteInto('id = ?', $id).
        $db->quoteInto(' AND userId = ?', $userId)
    );  
    if(!$row) {
        throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων/Δεν βρέθηκε εγγραφή που να ικανοποιεί τα συγκεκριμένα κριτήρια');
    }
    $algorithm = new ss_Object($row->toArray());
    $algorithm->userTags = array();
    $algorithm->globalTags = array();
    $gtrs = $row->findDependentRowset('Default_Model_DbTable_AlgorithmsGlobalTags');
    foreach($gtrs as $r) {
        $algorithm->globalTags[] = $r['globalTagId'];
    }
    $utrs = $row->findDependentRowset('Default_Model_DbTable_AlgorithmsUserTags');
    foreach($utrs as $r) {
        $algorithm->userTags[] = $r['userTagId'];
    }
    $ret = new stdClass();
    $ret->success = true;
    $ret->algorithm = $algorithm;
    return $ret;
}
function deleteAlgorithm($id)
{
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
    $table = new Default_Model_DbTable_Algorithm();
    $where = $db->quoteInto('id = ?', $id).$db->quoteInto(' AND userId = ?', $userId);  
    $res = $table->delete($where);
    if($res) {
        $ret = new stdClass();
        $ret->success = true;
        $ret->id = $id;
        return $ret;
    } else {
        throw new Zend_Amf_Server_Exception('Δεν βρέθηκε εγγραφή που να ικανοποιεί τα συγκεκριμένα κριτήρια');
    }
}

function saveAlgorithm($obj, $userTagIds = array(), $globalTagIds = array())
{
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
        
    $algorithm = new Default_Model_Algorithm();
    $form = $algorithm->getForm(false);
    $ret = new stdClass();
    if($form->isValid((array) $obj)) {
        $arr = $form->getValues();
        if($obj->id) {
            $id = $obj->id;
            $row = $algorithm->find($id);
            if($row->userId == $userId) {               
                $arr['algorithm']['id'] = $id;
                $algorithm->mapProperties($arr['algorithm']);
                $algorithm->save();             
            } else {
                throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων');
            }               
        }
        else {
            $arr['algorithm']['userId'] = $userId;
            $algorithm->mapProperties($arr['algorithm']);
            $algorithm->save();
            $id = $algorithm->id;   
        }
        tagAlgorithm($id, $userTagIds, 'user');
        tagAlgorithm($id, $globalTagIds,'global');
        $ret->success = true;
        $ret->algorithm = getAlgorithm($id)->algorithm;
        
    } else {
        $ret->success = false;
        $ret->messages = getFormMessages($form, 'algorithm');
    }
    return $ret;
}

function saveSettings($settings)
{
    $session = Zend_Registry::get('session');
    if(!$session->authUser) {
        throw new Zend_Amf_Server_Exception('Σφάλμα δικαιωμάτων');
    }
    $session->authUser->settings = $settings;
    $session->authUser->save();
}


function getUserAlgorithms($orderBy = 'name ASC', $page = 1, $limit = 5, $userTags = null, $globalTags = null)
{
    $db = Zend_Registry::get('db');
    $userId = getSessionUserId();
    
    $userTagsCount = count($userTags);
    $globalTagsCount = count($globalTags);
    
    
    $gSelect = $db->select();
    $gSelect->from('algorithms', '*');
    $gSelect->where('`algorithms`.`userId`= ?', $userId);
    $gSelect->order($orderBy);
    if($globalTagsCount) {
        $gSelect->join('algorithms-global_tags', '`algorithms`.`id`=`algorithms-global_tags`.`algorithmId`', '');
        $gSelect->where('`algorithms-global_tags`.`globalTagId` IN('.implode(',', $globalTags).') ');
        $gSelect->group('algorithms.id');
        $gSelect->having("COUNT(`algorithms`.`id`) = $globalTagsCount");
    }
    if($userTagsCount) {
        $uSelect = $db->select();
        $uSelect->from('algorithms', 'id');     
        $uSelect->join('algorithms-user_tags', '`algorithms`.`id`=`algorithms-user_tags`.`algorithmId`', '');
        $uSelect->where('`algorithms-user_tags`.`userTagId` IN('.implode(',', $userTags).') ');
        $uSelect->group('algorithms.id');
        $uSelect->having("COUNT(`algorithms`.`id`) = $userTagsCount");
        $exp = new Zend_Db_Expr('(' . $uSelect->__toString() . ')');
        $gSelect->join($exp, '`algorithms`.`id`=`t`.`id`', '');
    }
    $paginator = Zend_Paginator::factory($gSelect);
    $paginator->setCurrentPageNumber($page);
    $paginator->setItemCountPerPage($limit);
    $obj = new StdClass();
    $obj->success = true;
    $obj->currentPageNumber = $page;
    $obj->totalItemCount = $paginator->getTotalItemCount();
    $obj->items = (array)$paginator->getCurrentItems();
    attachTags($obj->items, $orderBy, 'global');
    attachTags($obj->items, $orderBy, 'user');
    return $obj;
}
function attachTags(&$items, $orderBy, $type) {
    if(count($items) > 0) {
        if($type == 'global') {
            $table = 'algorithms-global_tags';
            $idField = 'globalTagId';
            $algField = 'globalTags';
        } else {
            $table = 'algorithms-user_tags';
            $idField = 'userTagId';
            $algField = 'userTags';
        }
        $li = count($items);
        $ids = array();
        for($i = 0; $i < $li; $i++) {
            $ids[$items[$i]['id']] = $i;
            $items[$i][$algField] = array();
        }   
        $db = Zend_Registry::get('db');
        $tSelect = $db->select();
        $tSelect->from($table, '*');
        $tSelect->where("`$table`.`algorithmId` IN(".implode(',', array_keys($ids)).")");
        $tSelect->join('algorithms', "`algorithms`.`id`=`$table`.`algorithmId`", '');
        $tSelect->order('algorithms.'.$orderBy);
        $rows = $db->fetchAll($tSelect);    
        $j = 0;
        $lr = count($rows);
        for($i = 0; $i < $lr; $i++) {       
            $id = $rows[$i]['algorithmId'];
            $items[$ids[$id]][$algField][] = $rows[$i][$idField];
        }
    }
}


function makePassword() 
{
    // set password length
    $pw_length = 8;
    // set ASCII range for random character generation
    $lower_ascii_bound = 50;          // "2"
    $upper_ascii_bound = 122;       // "z"
    
    // Exclude special characters and some confusing alphanumerics
    // o,O,0,I,1,l etc
    $notuse = array (58,59,60,61,62,63,64,73,79,91,92,93,94,95,96,108,111);
    $i = 0;
    $password = '';
    while ($i < $pw_length) {
        mt_srand ((double)microtime() * 1000000);
        // random limits within ASCII table
        $randnum = mt_rand ($lower_ascii_bound, $upper_ascii_bound);
        if (!in_array ($randnum, $notuse)) {
            $password = $password . chr($randnum);
            $i++;
        }
    }   
    return $password;
}

function arrayToString($array)
{
    $s = '';
    foreach($array as $key => $value) {
        if(!is_array($value) && !is_object($value)) {
            $s .= ',' . $key . '=>' . $value;
        }
        else {
            $s .= arrayToString($value);
        }
    }
    return $s;
}

class SessionException extends Exception
{
    function __construct()
    {
        super('Αδυναμία ανάκτησης συνόδου');
    }
}
